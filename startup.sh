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

# 3. Install general Python dependencies from PyPI
pip install \
    gradio \
    opencv-python-headless \
    pillow \
    numpy \
    ultralytics \
    realesrgan

# 4. Install torch, torchvision, torchaudio from CUDA-compatible index
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 5. Clone Deep-Live-Cam repo
cd /workspace
if [ ! -d "Deep-Live-Cam" ]; then
    git clone https://github.com/hacksider/Deep-Live-Cam.git
fi
cd Deep-Live-Cam

# 6. Download YOLOv8 model weights (default: yolov8n)
yolo task=detect mode=predict model=yolov8n.pt || echo "✅ YOLOv8 model already cached or skipped"

# 7. Download Real-ESRGAN model
mkdir -p weights
wget -nc -O weights/RealESRGAN_x4plus.pth https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5/RealESRGAN_x4plus.pth

# 8. Launch the app with file upload fallback instead of webcam
echo "🚀 Launching Deep-Live-Cam..."

# Replace app.py temporarily to use video upload instead of webcam
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
