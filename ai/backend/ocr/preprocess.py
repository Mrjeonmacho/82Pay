import cv2
import numpy as np

def _clahe(gray: np.ndarray) -> np.ndarray:
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    return clahe.apply(gray)

def _sharpen(gray: np.ndarray) -> np.ndarray:
    kernel = np.array([[0,-1,0],[-1,5,-1],[0,-1,0]], dtype=np.float32)
    return cv2.filter2D(gray, -1, kernel)

def _adaptive_bin(gray: np.ndarray) -> np.ndarray:
    return cv2.adaptiveThreshold(
        gray, 255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        31, 8
    )

def preprocess(img_bgr: np.ndarray, mode: str = "basic") -> np.ndarray:
    """
    mode: none | basic | strong
    return: BGR image (OpenCV)
    """
    if mode == "none":
        return img_bgr

    # 1) resize (small text 대응) - 너무 크면 속도만 느려져서 2배까지만
    h, w = img_bgr.shape[:2]
    if max(h, w) < 1000:
        img_bgr = cv2.resize(img_bgr, (w * 2, h * 2), interpolation=cv2.INTER_CUBIC)

    gray = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)

    # 2) contrast improve
    gray = _clahe(gray)

    # 3) denoise
    gray = cv2.fastNlMeansDenoising(gray, h=10, templateWindowSize=7, searchWindowSize=21)

    # 4) sharpen
    gray = _sharpen(gray)

    if mode == "strong":
        # 5) binarize (영수증/계좌번호에 강함, 사진 상태 나쁘면 역효과도 가능)
        bw = _adaptive_bin(gray)
        return cv2.cvtColor(bw, cv2.COLOR_GRAY2BGR)

    return cv2.cvtColor(gray, cv2.COLOR_GRAY2BGR)