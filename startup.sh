#!/bin/bash
set -xe

echo "🔧 Starting Deep-Live-Cam Setup..."

# 1. Install system dependencies
apt-get update && apt-get install -y \
    libgl1 \
    wget \
    git \
    ffmpeg

# 2. Upgrade pip and install Python dependencies
pip install --upgrade pip
pip install \
    gradio \
    opencv-python-headless \
    pillow \
    numpy \
    torch \
    torchvision \
    torchaudio --index-url https://download.pytorch.org/whl/cu118

pip install ultralytics realesrgan

# 3. Clone Deep-Live-Cam repo
cd /workspace
if [ ! -d "Deep-Live-Cam" ]; then
    git clone https://github.com/hacksider/Deep-Live-Cam.git
fi
cd Deep-Live-Cam

# 4. Download YOLOv8 model weights (default: yolov8n)
yolo task=detect mode=predict model=yolov8n.pt || echo "✅ YOLOv8 model already cached or skipped"

# 5. Download Real-ESRGAN model
mkdir -p weights
wget -nc -O weights/RealESRGAN_x4plus.pth https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5/RealESRGAN_x4plus.pth

# 6. Launch the app
echo "🚀 Launching Deep-Live-Cam..."
python app.py --share
