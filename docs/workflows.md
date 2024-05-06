# Workflow documents
This document outline the various workflows in the both the mobile app frontend and backend.

## Disease Detection Workflow (Mobile UI)
This workflow diagram depicts the process the user goes through for selecting and uploading images for disease detection, and additionally the process of how results are displayed in App.

```mermaid
stateDiagram-v2
hp: Home Page
cp: Camera Page
irp: Inference Review \n Selection Page
rp: Review Page
pg: Photo Gallery
ui: Upload Indicator
ipi: In Progress Indicator
[*] --> hp
hp --> cp: upload image for \n disease detection
cp --> hp
hp --> irp: Review disease \n deteciton results
irp --> hp
irp --> rp
rp --> irp
rp --> ipi: Show if not \n finished processing 
ipi --> rp
cp --> pg: Upload image \n from gallery
pg --> cp
pg --> ui: Upload
cp --> ui: Upload
ui --> cp: Return after \n finishing upload
```
