import asyncio
from datetime import datetime
from typing import Dict, Tuple

import aiohttp
from bs4 import BeautifulSoup
from apscheduler.schedulers.blocking import BlockingScheduler
from apscheduler.triggers.interval import IntervalTrigger

import redis
from dotenv import load_dotenv
import os

import time

def now():
    return time.perf_counter()

#redis 연결
load_dotenv()

REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))
REDIS_TTL_SEC = int(os.getenv("REDIS_TTL_SEC", "180"))
REDIS_PASSWORD = os.getenv('REDIS_PASSWORD')

URLS = {
    "USDKRW": "https://finance.naver.com/marketindex/exchangeDailyQuote.nhn?marketindexCd=FX_USDKRW&page=1",
    "JPYKRW": "https://finance.naver.com/marketindex/exchangeDailyQuote.nhn?marketindexCd=FX_JPYKRW&page=1",
    "CNYKRW": "https://finance.naver.com/marketindex/exchangeDailyQuote.nhn?marketindexCd=FX_CNYKRW&page=1",
}

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                  "AppleWebKit/537.36 (KHTML, like Gecko) "
                  "Chrome/120.0.0.0 Safari/537.36",
    "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
    "Referer": "https://finance.naver.com/",
}

TIMEOUT_SEC = 5

r = redis.Redis(
    host=REDIS_HOST,
    port=REDIS_PORT,
    password=REDIS_PASSWORD,
    decode_responses=True
)


def parse_latest_date_and_rate(html: str) -> Tuple[str, str]:
    """
    반환: (날짜, 매매기준율)
    예: ("2026.03.06", "932.68")
    """

    start = now()

    soup = BeautifulSoup(html, "html.parser")

    # 네이버 금융 환율 표는 보통 table.tbl_exchange 에 들어있음
    table = soup.select_one("table.tbl_exchange")
    if not table:
        raise ValueError("환율 테이블(table.tbl_exchange)을 찾지 못했습니다.")

    # 첫 번째 데이터 행 (가장 최신)
    row = table.select_one("tbody > tr")
    if not row:
        raise ValueError("테이블 tbody의 첫 행(tr)을 찾지 못했습니다.")

    cols = [td.get_text(strip=True) for td in row.find_all("td")]
    # 예상 컬럼: [날짜, 매매기준율, 전일대비, 사실때, 파실때, ...]
    # 사용자 예시에서 '날짜 오른쪽 값' = 매매기준율 = cols[1]
    if len(cols) < 2:
        raise ValueError(f"컬럼 개수가 부족합니다. cols={cols}")

    latest_date = cols[0]
    base_rate = cols[1].replace(",", "")  # 혹시 천단위 콤마가 있으면 제거

    #print(f"[PARSE] parsing took {now() - start:.3f}s", flush=True)
    
    return latest_date, base_rate


async def fetch_html(session: aiohttp.ClientSession, url: str) -> str:

    start = now()

    async with session.get(url) as response:
        response.raise_for_status()
        raw = await response.read()

        # 네이버 페이지가 EUC-KR일 수 있으므로 우선 euc-kr 시도
        try:
            html = raw.decode("euc-kr")
        except UnicodeDecodeError:
            html = raw.decode("utf-8", errors="replace")

    #print(f"[HTTP] {url} took {now() - start:.3f}s", flush=True)
        
    return html


async def fetch_latest(session: aiohttp.ClientSession, symbol: str, url: str) -> Tuple[str, str]:
    html = await fetch_html(session, url)
    return parse_latest_date_and_rate(html)


async def fetch_all_latest() -> Dict[str, Tuple[str, str]]:
    timeout = aiohttp.ClientTimeout(total=TIMEOUT_SEC)

    connector = aiohttp.TCPConnector(limit=10, ssl=False)

    async with aiohttp.ClientSession(
        headers=HEADERS,
        timeout=timeout,
        connector=connector
    ) as session:
        tasks = {
            symbol: fetch_latest(session, symbol, url)
            for symbol, url in URLS.items()
        }

        results: Dict[str, Tuple[str, str]] = {}

        gathered = await asyncio.gather(*tasks.values(), return_exceptions=True)

        for symbol, result in zip(tasks.keys(), gathered):
            if isinstance(result, Exception):
                results[symbol] = ("ERROR", f"{type(result).__name__}: {result}")
            else:
                results[symbol] = result

        return results


def save_to_redis(results: Dict[str, Tuple[str, str]]) -> None:

    start = now()

    fetched_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    for symbol, (d, rate) in results.items():
        if d == "ERROR":
            continue

        key = f"fx:{symbol}"
        r.hset(key, mapping={
            "date": d,
            "rate": rate,
            "fetched_at": fetched_at
        })
        r.expire(key, REDIS_TTL_SEC)
    
    #print(f"[REDIS] save took {now() - start:.3f}s", flush=True)


def job_print_latest() -> None:

    job_start = now()

    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    try:
        results = asyncio.run(fetch_all_latest())
    except Exception as e:
        print(f"[FATAL] 전체 요청 실패: {type(e).__name__}: {e}", flush=True)
        return

    print(now_str, flush=True)
    for symbol in ["USDKRW", "JPYKRW", "CNYKRW"]:
        d, rate = results.get(symbol, ("ERROR", "NO_RESULT"))
        print(f"{symbol}\t{d}\t{rate}", flush=True)
    #print(f"(fetched_at: {now_str})", flush=True)
    print("-" * 40, flush=True)

    save_to_redis(results)

    #print(f"[JOB] total time {now() - job_start:.3f}s", flush=True)

def main() -> None:
    scheduler = BlockingScheduler(timezone="Asia/Seoul")

    # 즉시 1회 실행
    job_print_latest()

    # 1분 간격 실행 (겹침 방지: max_instances=1)
    scheduler.add_job(
        job_print_latest,
        trigger=IntervalTrigger(seconds=10),
        id="fx_job",
        max_instances=1,
        coalesce=True,
        misfire_grace_time=30,
    )

    try:
        scheduler.start()
    except (KeyboardInterrupt, SystemExit):
        pass


if __name__ == "__main__":
    main()