# PolySLAM

- https://www.youtube.com/watch?v=M1snRz7kav0
- https://www.slideshare.net/nourybouraqadi/on-2d-slam-for-large-indoor-spaces-a-polygonbased-solution
- Research paper [pdf](http://car.imt-lille-douai.fr/luc/files/pdfs/2019-jd-icarsc.pdf) [slides](http://car.imt-lille-douai.fr/luc/files/pdfs/2019-jd-icarsc-slides.pdf)
```
Johann Dichtl, Xuan Sang Le, Guillaume Lozenguez, Luc Fabresse and Noury Bouraqadi, PolySLAM: A 2D Polygon-based SLAM Algorithm, Proceedings of 19th IEEE International Conference on Autonomous Robot Systems and Competitions (ICARSC'2019), 2019, Best Paper Award in the "Industrial Robot" category,
```
- [J. DICHTL PHD](https://tel.archives-ouvertes.fr/tel-02492637)

# PolySLAM-PhaROS7

PolySLAM packages on PhaROS 7.0

To load the packages, use following snippet in a playground:

```Smalltalk
Metacello new
	repository: 'github://CARMinesDouai/PolySLAM-PhaROS7';
	baseline:'PolySLAM';
	load: #pharos
 "
 Change #pharos with other group name:
  - #core: load only the core PolySLAM package
  - #extra: load the core package and some extra utility classes
  - #test: load #core and test classes
  - #full:  load #core #extra and #test
  - #pharos: load #core and PhaROS
  - #pharosfull: load #pharos and extra example classes
 "
```
