import cv2
import numpy as np

def _clahe(gray: np.ndarray) -> np.ndarray:
    clahe = cv2.createCLAHE(clipLimit=2.5, tileGridSize=(8, 8))
    return clahe.apply(gray)

def _sharpen(gray: np.ndarray) -> np.ndarray:
    kernel = np.array([[0,-1,0],[-1,5,-1],[0,-1,0]], dtype=np.float32)
    return cv2.filter2D(gray, -1, kernel)

def _adaptive_bin(gray: np.ndarray) -> np.ndarray:
    return cv2.adaptiveThreshold(
        gray, 255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        25, 6
    )

def preprocess(img_bgr: np.ndarray, mode: str = "basic") -> np.ndarray:
    if mode == "none":
        return img_bgr

    h, w = img_bgr.shape[:2]

    if mode == "numeric":
        img_bgr = cv2.copyMakeBorder(
            img_bgr, 8, 8, 36, 16,
            cv2.BORDER_CONSTANT,
            value=(255, 255, 255)
        )

        h2, w2 = img_bgr.shape[:2]
        if max(h2, w2) < 1200:
            img_bgr = cv2.resize(
                img_bgr,
                (int(w2 * 2.5), int(h2 * 2.5)),
                interpolation=cv2.INTER_CUBIC
            )

        gray = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)
        gray = _clahe(gray)

        # 숫자용은 denoise를 더 약하게
        gray = cv2.fastNlMeansDenoising(
            gray,
            h=4,
            templateWindowSize=7,
            searchWindowSize=15
        )

        gray = _sharpen(gray)

        return cv2.cvtColor(gray, cv2.COLOR_GRAY2BGR)

    if mode == "numeric_strong":
        img_bgr = cv2.copyMakeBorder(
            img_bgr, 8, 8, 24, 14,
            cv2.BORDER_CONSTANT,
            value=(255, 255, 255)
        )

        h2, w2 = img_bgr.shape[:2]
        if max(h2, w2) < 1200:
            img_bgr = cv2.resize(
                img_bgr,
                (int(w2 * 2.5), int(h2 * 2.5)),
                interpolation=cv2.INTER_CUBIC
            )

        gray = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)
        gray = _clahe(gray)

        gray = cv2.fastNlMeansDenoising(
            gray,
            h=5,
            templateWindowSize=7,
            searchWindowSize=15
        )

        gray = _sharpen(gray)
        bw = _adaptive_bin(gray)

        kernel = np.ones((2, 2), np.uint8)
        bw = cv2.morphologyEx(bw, cv2.MORPH_CLOSE, kernel, iterations=1)

        return cv2.cvtColor(bw, cv2.COLOR_GRAY2BGR)

    if max(h, w) < 1000:
        img_bgr = cv2.resize(img_bgr, (w * 2, h * 2), interpolation=cv2.INTER_CUBIC)

    gray = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)
    gray = _clahe(gray)

    gray = cv2.fastNlMeansDenoising(
        gray,
        h=6,
        templateWindowSize=7,
        searchWindowSize=17
    )

    gray = _sharpen(gray)

    if mode == "strong":
        bw = _adaptive_bin(gray)
        kernel = np.ones((2, 2), np.uint8)
        bw = cv2.morphologyEx(bw, cv2.MORPH_CLOSE, kernel, iterations=1)
        return cv2.cvtColor(bw, cv2.COLOR_GRAY2BGR)

    return cv2.cvtColor(gray, cv2.COLOR_GRAY2BGR)