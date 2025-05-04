#!/bin/bash
set -xe

echo "🔧 Starting Deep-Live-Cam Setup..."

# 1. Install system dependencies
apt-get update && apt-get install -y \
    libgl1 \
    wget \
    git \
    ffmpeg

# 2. Upgrade pip
pip install --upgrade pip

# 3. Install Python dependencies
pip install \
    gradio \
    opencv-python-headless \
    pillow \
    numpy \
    ultralytics \
    realesrgan

# 4. Install PyTorch (CUDA 11.8 compatible)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 5. Use correct volume mount path to isolate from ComfyUI
cd /deeplivecam
if [ ! -d "Deep-Live-Cam" ]; then
    git clone https://github.com/hacksider/Deep-Live-Cam.git
fi
cd Deep-Live-Cam

# 6. Download YOLOv8 and Real-ESRGAN models
yolo task=detect mode=predict model=yolov8n.pt || echo "✅ YOLOv8 model already cached or skipped"

mkdir -p weights
wget -nc -O weights/RealESRGAN_x4plus.pth https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5/RealESRGAN_x4plus.pth

# 7. Patch inference.py to accept file input
sed -i 's/def run_pipeline(source=0):/def run_pipeline(source):/' inference.py

# 8. Launch Gradio UI
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

demo.launch(share=True, server_port=7860)
EOF

python gradio_ui.py
