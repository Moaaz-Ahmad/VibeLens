# Getting Started with VibeLens ML Training

This guide helps you **improve** the mood classification model with custom training. The app is already working with a pre-trained model!

## 🎯 Current Status

**You already have a working app!** ✅

- ✅ Pre-trained MobileNetV2 model deployed (`assets/models/mood_classifier.tflite`)
- ✅ App running on Android emulator (~700ms inference)
- ✅ Mood detection functional (e.g., "nostalgic 34.5%")
- ✅ No training dataset required for basic functionality

**This guide is for:** Improving accuracy from ~30-50% (pre-trained) to 75-90% (custom trained)

## 🎯 Overview

To train a custom model, you have three tasks:

1. **Collect training dataset** (needs images) - Optional but recommended
2. **Fine-tune or train model** (scripts ready) - Improves accuracy
3. **Convert to TFLite** (Google Colab ready) - Deploy improved model

---

## 📁 Step 1: Set Up Training Dataset

### Dataset Structure (Already Created ✅)

```
data/
├── train/          # 70-80% of your images
│   ├── cozy/
│   ├── energetic/
│   ├── melancholic/
│   ├── calm/
│   ├── nostalgic/
│   └── romantic/
├── val/            # 10-15% of your images
│   └── (same moods)
└── test/           # 10-15% of your images
    └── (same moods)
```

### Collect Images

**Minimum**: 100 images per mood (600 total)  
**Recommended**: 500+ images per mood (3,000+ total)

**Where to get images:**

- [Unsplash](https://unsplash.com) - High quality, free
- [Pexels](https://pexels.com) - Free stock photos
- [Pixabay](https://pixabay.com) - Free images

**Search terms by mood:**

🛋️ **Cozy**: "cozy living room", "fireplace", "warm blanket", "coffee cafe", "candles"

⚡ **Energetic**: "concert crowd", "party", "fireworks", "sports action", "dancing"

🌧️ **Melancholic**: "rain window", "empty bench", "gray sky", "foggy morning", "autumn"

🌊 **Calm**: "zen garden", "still water", "beach", "peaceful landscape", "meditation"

📸 **Nostalgic**: "vintage camera", "old photograph", "retro", "vinyl record", "sepia"

💕 **Romantic**: "couple sunset", "roses", "candlelit dinner", "heart", "holding hands"

### Organize Images

1. Download images for each mood
2. Place them in the appropriate folders:

   ```
   data/train/cozy/image1.jpg
   data/train/cozy/image2.jpg
   data/train/energetic/image1.jpg
   ...
   ```

3. **Split ratio**: Aim for 70% train, 15% val, 15% test
   - If you have 100 images per mood: 70 train, 15 val, 15 test

4. **Verify your dataset:**

   ```powershell
   cd ml
   python verify_dataset.py
   ```

   This will show you:
   - How many images per mood
   - Whether splits are balanced
   - Recommendations for improvement

---

## 🚀 Step 2: Start Training

### Option A: Fine-Tune Pre-trained Model (Recommended)

Start from the pre-trained MobileNetV2 weights for faster convergence:

```powershell
# Make sure you have Python virtual environment activated
E:\Apps\VibeLens\.venv\Scripts\python.exe ml\train_quickstart.py --pretrained --epochs 10 --batch_size 16
```

**What this does:**

- Starts from pre-trained ImageNet weights (better than random)
- Trains for 10 epochs (~5-10 minutes with small dataset)
- Uses batch size of 16 (adjust based on GPU memory)
- Saves best model to `models/checkpoints/best_model_quick.pth`
- Shows training progress and validation accuracy

**Expected output:**

```
🖥️  Device: cpu (or cuda if you have GPU)
📂 Loading datasets from: ../data
   Training samples: 420
   Validation samples: 90
🧠 Creating model...
   Trainable parameters: 2,230,278
🚀 Starting training for 10 epochs...
   Epoch 1/10 - Loss: 1.7892, Acc: 23.45%
   ...
✅ Training Complete!
   Best Validation Accuracy: 65.32%
```

### Option B: Full Training from Scratch

For maximum control, train from scratch (slower convergence):

```powershell
# Full training without pre-trained weights
E:\Apps\VibeLens\.venv\Scripts\python.exe ml\train_model.py --epochs 50 --batch_size 32 --lr 0.001

# Or with pre-trained weights (recommended)
E:\Apps\VibeLens\.venv\Scripts\python.exe ml\train_model.py --pretrained --epochs 50 --batch_size 32
```

**Parameters:**

- `--pretrained`: Start from ImageNet weights (highly recommended)
- `--epochs`: Number of training epochs (50-100 recommended)
- `--batch_size`: Batch size (32 for GPU, 16 for CPU)
- `--lr`: Learning rate (0.001 is default, 0.0001 for fine-tuning)
- `--model_name`: Save model with specific name

**Full training features:**

- Automatic data augmentation (rotation, flip, color jitter)
- Learning rate scheduling
- Early stopping if validation doesn't improve
- Detailed metrics logging
- Training visualizations

### Monitor Training

The training script will show:

- ✅ Real-time loss and accuracy
- ✅ Validation performance after each epoch
- ✅ Best model checkpointing
- ✅ Time per epoch

**Tips:**

- If accuracy is low (<50%), add more diverse images
- If validation accuracy << training accuracy, you're overfitting (add more data)
- GPU speeds up training 5-10x vs CPU

---

## 📱 Step 3: Convert to TFLite (Google Colab)

### Why Google Colab?

Your local Python doesn't have TensorFlow installed. Colab provides:

- ✅ Python 3.10 with TensorFlow pre-installed
- ✅ Free GPU for faster conversion
- ✅ No local setup needed

### Steps

1. **Open Colab notebook:**
   - Go to [Google Colab](https://colab.research.google.com)
   - Upload `colab_tflite_conversion.ipynb` from your project
   - Or: File → Upload notebook → Select the file

2. **Run cells in order** (click play button or Shift+Enter):
   - Cell 1: Install dependencies
   - Cell 2: Define MobileNetV2 architecture (matches your training)
   - Cell 3: Upload your `.pth` file from `models/checkpoints/`
   - Cell 4: Load PyTorch model
   - Cell 5: Export to ONNX
   - Cell 6: Convert to TensorFlow
   - Cell 7: Convert to TFLite with uint8 quantization
   - Cell 8: Test the model (verify uint8 input/output)
   - Cell 9: Download `mood_classifier.tflite`

3. **Deploy to Flutter:**

   ```powershell
   # Backup current model (optional)
   copy assets\models\mood_classifier.tflite assets\models\mood_classifier_old.tflite
   
   # Copy new trained model
   copy Downloads\mood_classifier.tflite assets\models\
   
   # Clean and rebuild
   flutter clean
   flutter pub get
   ```

4. **Assets are already configured in `pubspec.yaml`:**

   ```yaml
   flutter:
     assets:
       - assets/models/mood_classifier.tflite
   ```

---

## 🧪 Step 4: Test in Flutter App

1. **Run the app:**

   ```powershell
   flutter run
   ```

2. **Compare performance:**
   - **Before (pre-trained):** ~30-50% accuracy, somewhat random predictions
   - **After (custom trained):** 60-90% accuracy, better mood detection
   - **Inference time:** Should remain ~700ms or faster

3. **Test camera:**
   - Grant camera permissions when prompted
   - Capture images with clear mood representations
   - Verify predictions match expected moods
   - Check confidence scores (should be higher)

4. **Debug if needed:**
   - Check Flutter logs: Look for "🤖 Model loaded successfully"
   - Verify model path: `assets/models/mood_classifier.tflite`
   - Test with different lighting and scenes
   - Compare with pre-trained model results

---

## 📊 Expected Results

### Current (Pre-trained, No Custom Training)

- Accuracy: ~30-50% (not trained on moods)
- Status: ✅ **Already deployed and working**
- Best for: Testing app flow, UI development

### With Small Dataset (100-500 images per mood)

- Training accuracy: 60-75%
- Validation accuracy: 50-65%
- Improvement: **2x better** than pre-trained
- Good for: Production testing, MVP

### With Good Dataset (500-1000 images per mood)

- Training accuracy: 75-90%
- Validation accuracy: 70-80%
- Improvement: **3x better** than pre-trained
- Good for: Production release

### With Excellent Dataset (1000+ images per mood)

- Training accuracy: 85-95%
- Validation accuracy: 80-90%
- Improvement: **4x better** than pre-trained
- Good for: Professional/commercial use

---

## 🐛 Troubleshooting

### "No images found" during training

- ✅ Check images are in correct folders: `data/train/{mood}/`
- ✅ Verify image formats (JPG, PNG)
- ✅ Run `python verify_dataset.py` to check structure

### "Out of memory" during training

- ✅ Reduce batch size: `--batch_size 8` or `--batch_size 4`
- ✅ Close other applications
- ✅ Use CPU instead of GPU: `--device cpu`

### Low accuracy (<50%)

- ✅ Add more diverse images
- ✅ Check if images clearly represent the mood
- ✅ Ensure balanced dataset (similar number per mood)
- ✅ Train for more epochs

### Model doesn't work in Flutter

- ✅ Check .tflite file exists: `assets/models/mood_classifier.tflite`
- ✅ Verify `pubspec.yaml` includes assets (already configured)
- ✅ Run `flutter clean` then `flutter pub get`
- ✅ Check model input size matches (224x224)
- ✅ Verify uint8 quantization (not float32)

### uint8 vs float32 issues

- ✅ Model must use uint8 quantization in Colab conversion
- ✅ Input preprocessing: resize to 224×224, keep as uint8 [0-255]
- ✅ Output: uint8 [0-255], converted to probabilities in Dart
- ✅ See `lib/services/model_service.dart` for implementation

### Python / TensorFlow issues

- ✅ Use virtual environment: `E:\Apps\VibeLens\.venv\Scripts\python.exe`
- ✅ Use PyTorch for training (no TensorFlow needed locally)
- ✅ Use Google Colab for TFLite conversion
- ✅ See `PYTHON_VERSION_NOTES.md` for compatibility details

---

## 📚 Additional Resources

### Documentation Files

- `README.md` - Project overview and quick start
- `ARCHITECTURE.md` - System architecture and design
- `PRETRAINED_QUICKSTART.md` - Using pre-trained model (already done)
- `PROJECT_STRUCTURE.md` - File organization
- `data/README.md` - Dataset collection guide
- `ml/INSTALL.md` - Python environment setup
- `PYTHON_VERSION_NOTES.md` - Python compatibility

### Helpful Commands

```powershell
# Verify dataset structure
E:\Apps\VibeLens\.venv\Scripts\python.exe ml\verify_dataset.py

# Quick fine-tuning (recommended)
E:\Apps\VibeLens\.venv\Scripts\python.exe ml\train_quickstart.py --pretrained --epochs 10

# Full training
E:\Apps\VibeLens\.venv\Scripts\python.exe ml\train_model.py --pretrained --epochs 50

# Check installed packages
E:\Apps\VibeLens\.venv\Scripts\pip.exe list

# Flutter commands
flutter clean
flutter pub get
flutter run
flutter test
```

---

## ✅ Quick Checklist

**Current Status:**
- [x] App working with pre-trained model ✅
- [x] Dataset structure created ✅
- [x] TFLite conversion pipeline ready ✅

**To Improve Accuracy:**
- [ ] Collect 100-1000 images per mood (6 moods total)
- [ ] Organize images in `data/train/`, `data/val/`, `data/test/`
- [ ] Run `verify_dataset.py` - verify structure
- [ ] Fine-tune with `train_quickstart.py --pretrained`
- [ ] Monitor training - accuracy should improve
- [ ] Convert trained model to TFLite via Colab
- [ ] Deploy new .tflite to `assets/models/`
- [ ] Test in app - compare with pre-trained results

---

## 🎉 Next Steps

### Immediate (App is Working)
1. **Test current functionality** - Camera, mood detection, UI
2. **Complete Spotify integration** - Playlist generation
3. **Add more tests** - Integration and widget tests

### Short-term (Improve Accuracy)
1. **Collect dataset** - 500+ images per mood
2. **Fine-tune model** - Use `--pretrained` flag
3. **Deploy improved model** - Compare results

### Long-term (Production Ready)
1. **Optimize performance** - Target <200ms inference
2. **Comprehensive testing** - 85%+ coverage
3. **Release preparation** - App store deployment

---

## 💡 Tips for Success

1. **Start small**: Fine-tune with 100 images per mood first
2. **Use pre-trained weights**: Always use `--pretrained` flag for faster convergence
3. **Test quickly**: Use `train_quickstart.py` before committing to full training
4. **Iterate**: Add more images if accuracy is low after first training
5. **Balance**: Keep similar numbers per mood for best results
6. **Quality over quantity**: Clear, representative images work best
7. **Use Colab**: Essential for TFLite conversion (TensorFlow not needed locally)
8. **Virtual environment**: Always use `E:\Apps\VibeLens\.venv\Scripts\python.exe`

---

## 🆘 Need Help?

If you get stuck:

1. **Check if app is working first** - Pre-trained model should already work
2. Review error messages carefully
3. Check relevant documentation files
4. Run `verify_dataset.py` before training
5. Test with small dataset (100 images) before large one
6. Compare with pre-trained model results

**Common errors documented in:**

- `ARCHITECTURE.md` - uint8 handling, model service details
- `PRETRAINED_QUICKSTART.md` - Pre-trained model setup (already done)
- `ml/INSTALL.md` - Python environment setup
- `PYTHON_VERSION_NOTES.md` - Python/TensorFlow compatibility
- This file - Training and conversion issues

**Key reminder:** You already have a working app! This guide is only for improving accuracy beyond the pre-trained baseline.

Good luck with training! 🚀
