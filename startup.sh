#!/bin/bash
set -xe

echo "🔧 Starting Deep-Live-Cam Setup..."

apt-get update && apt-get install -y \
    libgl1 \
    wget \
    git \
    ffmpeg

pip install --upgrade pip

pip install \
    gradio \
    opencv-python-headless \
    pillow \
    numpy \
    ultralytics \
    realesrgan

pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Use the correct volume mount path
cd /deeplivecam
if [ ! -d "Deep-Live-Cam" ]; then
    git clone https://github.com/hacksider/Deep-Live-Cam.git
fi
cd Deep-Live-Cam

yolo task=detect mode=predict model=yolov8n.pt || echo "✅ YOLOv8 model already cached or skipped"

mkdir -p weights
wget -nc -O weights/RealESRGAN_x4plus.pth https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5/RealESRGAN_x4plus.pth

sed -i 's/def run_pipeline(source=0):/def run_pipeline(source):/' inference.py

echo "🚀 Launching Deep-Live-Cam..."

cat > gradio_ui.py << 'EOF'
import gradio as gr
from inference import run_pipeline

def process(video_file):
    return run_pipeline(video_file.name)

demo = gr.Interface(fn=process,
                    inputs=gr.Video(label="Upload a video (no webcam on RunPod)"),
                    outputs=gr.Video(label="Enhanced output"),
                    title="Deep Live Cam (RunPod Edition)")

demo.launch(share=True)
EOF

python gradio_ui.py
