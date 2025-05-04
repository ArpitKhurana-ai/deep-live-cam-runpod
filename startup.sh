
#!/bin/bash
set -xe

# ✅ Log output to file for debugging
mkdir -p /app && rm -rf /app/startup.log
exec > >(tee /app/startup.log) 2>&1

echo "🔧 Setting up Deep-Live-Cam (GPU CUDA Mode)..."

# ✅ Timezone setup (optional)
ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime &&     dpkg-reconfigure -f noninteractive tzdata || true

# ✅ Install system dependencies
apt-get update && apt-get install -y     libgl1     wget     git     ffmpeg     python3-pip     curl

# ✅ Upgrade pip
pip install --upgrade pip

# ✅ Install Python dependencies
pip install     opencv-python-headless     pillow     numpy     gfpgan     gradio     onnxruntime-gpu==1.16.3     torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118     realesrgan

# ✅ Prepare isolated project folder
mkdir -p /workspace/deepcam
cd /workspace/deepcam

# ✅ Clone Deep-Live-Cam repo (skip if exists)
if [ ! -d "Deep-Live-Cam" ]; then
    git clone https://github.com/hacksider/Deep-Live-Cam.git
fi
cd Deep-Live-Cam

# ✅ Install ultralytics and YOLOv8 weights
pip install ultralytics
yolo task=detect mode=predict model=yolov8n.pt || echo "✅ YOLOv8 already cached or skipped"

# ✅ Download required face-swap models
mkdir -p models
wget -nc -O models/GFPGANv1.4.pth https://github.com/TencentARC/GFPGAN/releases/download/v1.3.8/GFPGANv1.4.pth
wget -nc -O models/inswapper_128_fp16.onnx https://github.com/hacksider/Deep-Live-Cam/releases/download/v1.0/inswapper_128_fp16.onnx

# ✅ Launch Deep-Live-Cam via Gradio on RunPod port
echo "🚀 Launching Deep-Live-Cam with CUDA acceleration..."
python run.py --execution-provider cuda --host 0.0.0.0 --port 7860
