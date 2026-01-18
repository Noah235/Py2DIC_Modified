# Py2DIC_Modified

Hobby project extending **Py2DIC** (2D DIC software from Sapienza University).[web:1][web:5]

**Original Py2DIC**: https://github.com/Geod-Geom/py2DIC[web:1]

## Features

**From Py2DIC (unmodified core)**:
- Full 2D Digital Image Correlation

**My modifications**:
- Cleaner export functionality
- Streamlined GUI
- Code cleanup

**New additions**:
- MATLAB scripts for ROI selection
- Image preprocessing tools

## License

Non-commercial only. See [LICENSE](LICENSE).[web:1]

## Usage

**Python DIC**:
1. `pip install -r requirements.txt`
2. `python main.py`

**MATLAB preprocessing**:
1. Run `roi_selection.m` on your images
2. Export ROIs → feed to Py2DIC
