# Kayak Stroke Data Field (Forerunner 970)

This directory is a **separate Connect IQ data-field project** for the Garmin Forerunner 970. It adds a kayak stroke counter with live cadence, watch tilt, and user-adjustable stroke detection settings. The existing standalone prototype at the repository root is unchanged.

## What it displays

- Detected strokes and strokes per minute.
- Watch tilt relative to gravity, in degrees. This is the watch's orientation, not a measured paddle-blade angle.
- Power and force are shown as unavailable. The watch accelerometer alone cannot measure paddle force or reliable watts; a compatible power/force sensor and a supported integration are needed. The app deliberately does not invent these values.

## Adjustable stroke detection

Open the data field's Connect IQ app settings to adjust:

- **Detection signal**: acceleration magnitude, X, Y, Z, or gravity-aligned vertical motion.
- **Threshold**: minimum acceleration change (g) to recognize a stroke.
- **Minimum interval**: cooldown in milliseconds to prevent a single movement being counted repeatedly.

The settings are intended as practical tuning controls, not a guarantee of accurate detection. Boat mounting, waves, watch orientation, and paddling technique all affect the signal. Start with a low-risk test and compare the counter with a manual count.

## Build

1. Install Garmin Connect IQ SDK Manager and the Monkey C VS Code extension.
2. Open `data-field/` as the Connect IQ project and select the Forerunner 970 target.
3. Build and test in the simulator, then install on the watch and add **Kayak Stroke Data Field** to a compatible activity screen.

The Connect IQ SDK/device must allow accelerometer listeners for this data-field app. If the SDK rejects listener registration or the watch does not deliver samples in the data-field context, stroke detection and tilt cannot operate there; validate on the target SDK before relying on it. No build was run while authoring these files.
