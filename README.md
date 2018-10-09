# PolySLAM-PhaROS7

PolySLAM packages on PhaROS 7.0

To load the packages, use following snippet in a playground:

```Smalltalk
Metacello new
	repository: 'github://CARMinesDouai/PolySLAM-PhaROS7';
	baseline:'PolySLAM';
	load: #default
 "
 Change #default with other group name:
  - #core: load only the core PolySLAM package
  - #extra: load the core package and some extra utility classes
  - #test: load #core and test classes
  - #full or #default:  load #core #extra and #test
  - #pharos: load #core and PhaROS
  - #pharosfull: load #pharos and extra example classes
 "
```
