# VibeLens Training Dataset

## Directory Structure

```
data/
├── train/          # Training images (70-80% of dataset)
│   ├── cozy/
│   ├── energetic/
│   ├── melancholic/
│   ├── calm/
│   ├── nostalgic/
│   └── romantic/
├── val/            # Validation images (10-15% of dataset)
│   ├── cozy/
│   ├── energetic/
│   ├── melancholic/
│   ├── calm/
│   ├── nostalgic/
│   └── romantic/
└── test/           # Test images (10-15% of dataset)
    ├── cozy/
    ├── energetic/
    ├── melancholic/
    ├── calm/
    ├── nostalgic/
    └── romantic/
```

## Mood Categories

### 1. Cozy 🛋️
**Vibe**: Warm, comfortable, intimate
- **Visual cues**: Warm lighting, soft textures, blankets, candles, fireplaces
- **Colors**: Warm browns, oranges, soft yellows, muted reds
- **Settings**: Living rooms, cafes, warm indoor spaces
- **Examples**: Coffee in a cozy corner, reading by the fireplace, warm sweaters

### 2. Energetic ⚡
**Vibe**: Dynamic, vibrant, high-energy
- **Visual cues**: Bright colors, action, movement, crowds, celebrations
- **Colors**: Bright reds, oranges, yellows, neon colors
- **Settings**: Parties, concerts, sports, festivals, busy urban scenes
- **Examples**: Dancing crowds, fireworks, sports action, vibrant street art

### 3. Melancholic 🌧️
**Vibe**: Reflective, somber, introspective
- **Visual cues**: Rain, gray skies, empty spaces, muted tones
- **Colors**: Grays, dark blues, muted purples, desaturated colors
- **Settings**: Rainy windows, empty streets, solitary figures, autumn scenes
- **Examples**: Rain on windows, lonely benches, fading flowers, overcast skies

### 4. Calm 🌊
**Vibe**: Peaceful, serene, tranquil
- **Visual cues**: Nature, water, minimalism, clear skies, symmetry
- **Colors**: Light blues, greens, whites, pastels
- **Settings**: Beaches, lakes, forests, meditation spaces, minimalist interiors
- **Examples**: Still water, zen gardens, clear horizons, gentle landscapes

### 5. Nostalgic 📸
**Vibe**: Sentimental, vintage, reminiscent
- **Visual cues**: Vintage items, old photos, retro aesthetics, faded colors
- **Colors**: Sepia tones, faded colors, warm vintage filters
- **Settings**: Old objects, childhood scenes, vintage settings
- **Examples**: Old photographs, vinyl records, vintage cameras, childhood toys

### 6. Romantic 💕
**Vibe**: Loving, intimate, tender
- **Visual cues**: Couples, flowers, soft lighting, hearts, embraces
- **Colors**: Pinks, reds, soft purples, warm golden hour tones
- **Settings**: Candlelit dinners, sunset scenes, flower gardens, intimate moments
- **Examples**: Rose bouquets, couple silhouettes, candlelight, heart shapes

## Dataset Guidelines

### Recommended Dataset Sizes
- **Minimum**: 100 images per mood (600 total)
- **Good**: 500 images per mood (3,000 total)
- **Excellent**: 1,000+ images per mood (6,000+ total)

### Splitting Ratio
- **Training**: 70-80% of images
- **Validation**: 10-15% of images
- **Testing**: 10-15% of images

### Image Requirements
- **Format**: JPG, PNG
- **Resolution**: Minimum 224x224 (will be resized during training)
- **Quality**: Clear, well-lit images
- **Diversity**: Varied angles, lighting conditions, compositions
- **Authenticity**: Real photos preferred over stock/staged images

## Data Collection Sources

### Free Image Datasets
1. **Unsplash** (https://unsplash.com) - High-quality free photos
2. **Pexels** (https://pexels.com) - Free stock photos
3. **Pixabay** (https://pixabay.com) - Free images and videos
4. **Wikimedia Commons** - Public domain images

### Search Terms by Mood

**Cozy**:
- "cozy living room", "warm blanket", "fireplace", "candlelight", "coffee cafe"
- "warm interior", "hygge", "knitting", "reading nook"

**Energetic**:
- "concert crowd", "party celebration", "sports action", "fireworks"
- "dancing", "festival", "neon lights", "urban nightlife"

**Melancholic**:
- "rain window", "empty bench", "gray sky", "autumn leaves"
- "solitude", "foggy morning", "abandoned", "lone figure"

**Calm**:
- "zen garden", "still water", "minimalist", "peaceful landscape"
- "meditation", "beach sunset", "forest path", "serene lake"

**Nostalgic**:
- "vintage camera", "old photograph", "retro", "sepia"
- "vinyl record", "antique", "childhood toys", "faded memories"

**Romantic**:
- "couple sunset", "rose bouquet", "candlelit dinner", "holding hands"
- "heart shape", "wedding", "love", "romantic picnic"

## Quick Start

### 1. Collect Images
Place images in the appropriate mood folders under `train/`, `val/`, and `test/`.

### 2. Verify Structure
Run the verification script:
```bash
python ml/verify_dataset.py
```

### 3. Start Training
```bash
cd ml
python train_model.py --data_dir ../data --epochs 50 --batch_size 32
```

## Data Augmentation

The training script automatically applies:
- Random horizontal flips
- Random rotation (±15°)
- Color jitter (brightness, contrast, saturation)
- Random cropping and resizing

This increases effective dataset size and improves model generalization.

## Tips for Quality Dataset

1. **Balance**: Ensure similar number of images per mood
2. **Diversity**: Include various lighting, angles, and compositions
3. **Clarity**: Avoid blurry or low-quality images
4. **Relevance**: Images should clearly represent the mood
5. **Authenticity**: Real-world photos work better than heavily edited stock photos
6. **Remove Duplicates**: Avoid near-identical images

## Need Help?

- Check `ml/INSTALL.md` for environment setup
- See `ml/train_model.py` for training options
- Review `PYTHON_VERSION_NOTES.md` for Python compatibility

## License Considerations

When collecting images:
- ✅ Use properly licensed images (CC0, Public Domain, or with permission)
- ✅ Respect photographer credits
- ✅ For commercial use, verify license allows it
- ❌ Don't use copyrighted images without permission
