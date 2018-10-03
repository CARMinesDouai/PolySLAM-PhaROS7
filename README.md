# PolySLAM-PhaROS7
PolySLAM packages for PhaROS 7.0

To load the packages, use following snippet in an playground

```Smalltalk
Metacello new
	repository: 'github://CARMinesDouai/PolySLAM-PhaROS7';
	baseline:'PolySLAM';
	load: #pharos
  "
  Change #pharos with other group name:
  - #core: load only the core package of PolySLAM
  - #extra: load the core classes and extra utility classes
  - #test: load the core and test classes
  - #pharos: load the PolySLAM-Core and PhaROS packages
  - #pharosfull: load the #pharos group with extra example classes
  "
```
