#!/bin/bash
set -xe

echo "🔧 Starting Deep-Live-Cam Setup..."

# 1. System packages
apt-get update && apt-get install -y libgl1 wget git ffmpeg

# 2. Upgrade pip & install Python deps
pip install --upgrade pip
pip install gradio opencv-python-headless pillow numpy torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install ultralytics realesrgan

# 3. Clone repo
cd /workspace
git clone https://github.com/hacksider/Deep-Live-Cam.git
cd Deep-Live-Cam

# 4. Download YOLOv8 model (default = yolov8n)
yolo task=detect mode=predict model=yolov8n.pt

# 5. Download Real-ESRGAN model
mkdir -p weights
wget -O weights/RealESRGAN_x4plus.pth https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5/RealESRGAN_x4plus.pth

# 6. Run app
echo "🚀 Launching Deep-Live-Cam..."
python app.py --share
