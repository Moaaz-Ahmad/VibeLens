"""Build assets/models/mood_classifier.tflite from Keras MobileNetV2.

    pip install tensorflow          # needs a TF-supported Python (3.9-3.12)
    python ml/build_model.py                 # data/train/<mood>/*.jpg optional
    python ml/build_model.py --epochs 10

Backbone: tf.keras.applications.MobileNetV2 (ImageNet weights, frozen).
Head: GlobalAveragePooling -> Dropout -> Dense(6, softmax).
If data/train exists the head is trained on it; otherwise the head stays
RANDOM and the script says so -- predictions are then meaningless.

App contract (lib/services/model_service.dart): input [1,224,224,3] raw RGB
0..255 float32 (rescaling to [-1,1] is inside the model), output 6 softmax
scores in LABELS order == MoodLabel enum order in lib/models/mood_result.dart.
"""
import argparse
import pathlib

import tensorflow as tf

LABELS = ["cozy", "energetic", "melancholic", "calm", "nostalgic", "romantic"]
SIZE = 224
ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "models" / "mood_classifier.tflite"


def build():
    base = tf.keras.applications.MobileNetV2(
        input_shape=(SIZE, SIZE, 3), include_top=False, weights="imagenet"
    )
    base.trainable = False
    inp = tf.keras.Input((SIZE, SIZE, 3))
    x = tf.keras.layers.Rescaling(1 / 127.5, offset=-1)(inp)  # == preprocess_input
    x = base(x, training=False)
    x = tf.keras.layers.GlobalAveragePooling2D()(x)
    x = tf.keras.layers.Dropout(0.2)(x)
    out = tf.keras.layers.Dense(len(LABELS), activation="softmax")(x)
    return tf.keras.Model(inp, out)


def load(split, shuffle):
    d = ROOT / "data" / split
    if not d.is_dir():
        return None
    return tf.keras.utils.image_dataset_from_directory(
        d, labels="inferred", class_names=LABELS, label_mode="categorical",
        image_size=(SIZE, SIZE), batch_size=16, shuffle=shuffle,
    )


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--epochs", type=int, default=10)
    args = ap.parse_args()

    model = build()
    train, val = load("train", True), load("val", False)
    if train is None:
        print("WARNING: data/train not found -> classifier head is UNTRAINED (random).")
    else:
        model.compile("adam", "categorical_crossentropy", metrics=["accuracy"])
        model.fit(train, validation_data=val, epochs=args.epochs)
        test = load("test", False)
        if test is not None:
            loss, acc = model.evaluate(test)
            print(f"test accuracy: {acc:.3f} (chance = {1 / len(LABELS):.3f})")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_bytes(tf.lite.TFLiteConverter.from_keras_model(model).convert())
    print("wrote", OUT)


if __name__ == "__main__":
    main()
