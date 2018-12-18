"
This is the base class for the gnuplot plotter.


The gnuplot plotter is using gnuplot via the command line interface in conjunction with pipes to create graphs and figures that visualizes
objects, similar to the classes and methods in the 'GUI-Athens' tag. each #plot call will create a seperate window that visualizes the state
of the object at the time of the message call. Later state changes of the object will not be reflected in the figure. That means that the plotter
is not designed to show live changes. Indeed, its main purpose is to create graphs to be used in LaTex documents.

note, that the plot commands and the data points are collected seperatly (in the variables plotCmd and plotDate) because gnuplot
requires all plot commands before we can pass the data.


Public API and Key Messages

- plot
	after instance creation, this method starts the whole rendering process and spawns the external persistent window
- plotOn: <subProcess>
	this method is called by #plot and should be implemented by any derived classes to start the plotting for the specific instance.


Instance creation:
	being a base class, there should be no instances of this class created. derived classes can use the #model: class-side method
	for instance creation or provide their own methods.


Internal Representation and Key Implementation Points.

Instance Variables
	crlf
		String instance that contains \r\n. provided  for convenience
	model
		the object that is visualized bu the plotter
	plotCmd
		a string stream that contains the ""plot"" line of the pipe stream
	plotData
		a string stream that contains the data points for the plot



"
Class {
	#name : #VMPlotter,
	#superclass : #Object,
	#instVars : [
		'model',
		'crlf',
		'plotCmd',
		'plotData',
		'plotInitStream',
		'autoColor',
		'lineWidth',
		'dataSetCounter',
		'labelCounter',
		'objectCounter',
		'range'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #accessing }
VMPlotter class >> model: anObject [
	^(self new)
		model: anObject;
		yourself
]

{ #category : #'as yet unclassified' }
VMPlotter >> addInitLine: aString [
	"adds aString to the init part of the gnuplot command stream. automatically adds crlf at the end.
	This method is used to add custom settings that are not otherwise implemented."
	plotInitStream nextPutAll: aString; crlf.
]

{ #category : #accessing }
VMPlotter >> autoColor [
	^ autoColor
]

{ #category : #accessing }
VMPlotter >> autoColor: aBoolean [
	autoColor := aBoolean.
]

{ #category : #accessing }
VMPlotter >> circleAt: center radius: radius numSegments: segCount [
	| deltaAngle angle points |
	
	deltaAngle := Float twoPi / segCount.
	angle := 0.0.
	points := OrderedCollection new.
	
	1 to: segCount do: [ :i |
		points add: ((angle cos) @ (angle sin)) * radius + center.
		angle := angle + deltaAngle.
	].
	
	^VMPolygon fromPoints: points

]

{ #category : #accessing }
VMPlotter >> cmdStream [
	^ plotCmd
]

{ #category : #'as yet unclassified' }
VMPlotter >> createDataID [
	dataSetCounter := dataSetCounter + 1.
	^ '$DataSet', dataSetCounter printString
]

{ #category : #accessing }
VMPlotter >> crlf [
	^ crlf
]

{ #category : #accessing }
VMPlotter >> dataStream [
	^ plotData
]

{ #category : #accessing }
VMPlotter >> initStream [
	^ plotInitStream
]

{ #category : #initialization }
VMPlotter >> initialize [
	crlf := Character cr asString, Character lf asString.
	plotInitStream := String new writeStream.
	plotCmd := String new writeStream.
	plotData := String new writeStream.
	
	lineWidth := 1.
	autoColor := true.
	dataSetCounter := 0. "unused at the moment, since named data blocks seem to not work when piping to gnuplot"
	labelCounter := 0. "running number to create ids for labeling items"
	objectCounter := 0. "running number to create ids for gnuplot 'objects'."
	range := nil.	"nil = auto / let gnuplot decide"
	
	plotInitStream
		nextPutAll: 'set encoding utf8';
		nextPutAll: crlf.
		"nextPutAll: 'set lable size 14';
		nextPutAll: crlf."
]

{ #category : #accessing }
VMPlotter >> labelCounter [
	"provides an unused label counter"
	labelCounter := labelCounter + 1.
	^ labelCounter
]

{ #category : #accessing }
VMPlotter >> lineWidth: aNumber [
	lineWidth := aNumber.
]

{ #category : #accessing }
VMPlotter >> model: anObject [
	model := anObject.
]

{ #category : #plotting }
VMPlotter >> plot [
	| process |
	
	process := self plotInit.
		
	self plotOn: process.
	self plotExec: process.	
	
	"Transcript show: plotCmd contents;
		show: crlf;
		show: plotData contents;
		cr; cr."
	"self printDebug."
	
	self plotFinish: process.
	

]

{ #category : #'plotting - helper' }
VMPlotter >> plotArcFrom: startAngle to: stopAngle at: center radius: radius [
	"0 degree points to the positive x-axis (i.e. right).
	positive angle rotates counter-clockwise"
	| steps points deltaAngle angle vectors |
	
	steps := 20.
	points := OrderedCollection new.
	vectors := OrderedCollection new.
	deltaAngle := stopAngle - startAngle / steps.
	angle := startAngle.
	
	0 to: steps do: [ :i |
		points add: ((angle cos) @ (angle sin)) * radius + center.
		angle := angle + deltaAngle.
	].
	
	1 to: steps do: [ :i |
		vectors add: (VMLineSegment from: (points at: i) to: (points at: i+1)).
	].

	vectors do: [ :v | self plotLineSegment: v extra: 'nohead lc rgb "#000000" dt 1 notitle'. ].
	
	
]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotArrow: aVector extra: extraString [

	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2:3:4 with vectors';
		nextPutAll: ' t '''' ';
		nextPutAll: extraString.

	plotData
		nextPutAll: aVector pointA x printString;
		nextPutAll: ' ';
		nextPutAll: aVector pointA y printString;
		nextPutAll: ' ';
		nextPutAll: aVector direction x printString;
		nextPutAll: ' ';
		nextPutAll: aVector direction y printString;
		nextPutAll: crlf.
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotArrowCollection: aCollection [
	
	autoColor ifTrue: [
		plotInitStream	
			nextPutAll: 'set style arrow 1 lt 1 lc rgb "red" lw ', lineWidth printString, crlf;
			nextPutAll: 'set style arrow 2 lt 1 lc rgb "green" lw ', lineWidth printString, crlf;
			nextPutAll: 'set style arrow 3 lt 1 lc rgb "#FFCAA300" nohead ', lineWidth printString, crlf.
	].
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2:3:4:5 with vectors arrowstyle var';
		nextPutAll: ' t '''''.

	aCollection doWithIndex: [ :vec :index |
		plotData
			nextPutAll: vec pointA x printString;
			nextPutAll: ' ';
			nextPutAll: vec pointA y printString;
			nextPutAll: ' ';
			nextPutAll: vec direction x printString;
			nextPutAll: ' ';
			nextPutAll: vec direction y printString;
			nextPutAll: ' ';
			nextPutAll: vec type asInteger printString;
			nextPutAll: crlf.
	].
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotArrowCollection: aCollection extra: extraString [
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2:3:4 with vectors';
		nextPutAll: ' t '''' ';
		nextPutAll: extraString.

	aCollection doWithIndex: [ :vec :index |
		plotData
			nextPutAll: vec pointA x printString;
			nextPutAll: ' ';
			nextPutAll: vec pointA y printString;
			nextPutAll: ' ';
			nextPutAll: vec direction x printString;
			nextPutAll: ' ';
			nextPutAll: vec direction y printString;
			nextPutAll: crlf.
	].
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - helper' }
VMPlotter >> plotBackground [
	range ifNil: [ ^ self ].
	self plotFilledPolygon: (VMPolygon fromRectangle: range) extra: 'lc rgb "#CCCCCC"'.
]

{ #category : #plotting }
VMPlotter >> plotChild: aPlotObj [
	"plots the child in self. the child is responsible for creating unique ids where needed"
	aPlotObj plotParent: self.


]

{ #category : #'plotting - helper' }
VMPlotter >> plotConnectedPoints: aCollection extra: extraString [
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', "" ' ]);
		nextPutAll: 'using 1:2 ';"with points ';"
		nextPutAll: extraString.
	
	aCollection do: [ :aPoint |
		plotData
			nextPutAll: aPoint x printString;
			nextPutAll: ' ';
			nextPutAll: aPoint y printString;
			nextPutAll: crlf.
	].
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - helper' }
VMPlotter >> plotDot: aPoint radius: radius extra: extraString [
	| circle |
	circle := self circleAt: aPoint radius: radius numSegments: 12.
	
	self plotFilledPolygon: circle extra: extraString.
]

{ #category : #'plotting - execution' }
VMPlotter >> plotExec: process [

	process stdinStream
		nextPutAll: plotInitStream contents;
		nextPutAll: plotCmd contents;
		nextPutAll: crlf;
		nextPutAll: plotData contents.

]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotFilledPolygon: polygon [
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2 with filledcurves closed notitle lc rgb "#FFAA00"'.

	polygon do: [ :vec |
		plotData
			nextPutAll: vec pointA x printString;
			nextPutAll: ' ';
			nextPutAll: vec pointA y printString;
			nextPutAll: crlf.
	].
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotFilledPolygon: polygon extra: extraString [
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2 with filledcurves closed notitle ';
		nextPutAll: extraString.

	polygon do: [ :vec |
		plotData
			nextPutAll: vec pointA x printString;
			nextPutAll: ' ';
			nextPutAll: vec pointA y printString;
			nextPutAll: crlf.
	].
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - execution' }
VMPlotter >> plotFinish: process [
	process stdinStream nextPutAll: 'exit', crlf.
"	process stdinStream close."
	"process waitForExit.
	process closeAndCleanStreams."

]

{ #category : #'plotting - helper' }
VMPlotter >> plotGridFrom: pointA to: pointB by: stepSize [
	| top bottom left right |
	left := pointA x min: pointB x.
	right := pointA x max: pointB x.
	top := pointA y min: pointB y.
	bottom := pointA y max: pointB y.
	
	plotInitStream
		nextPutAll: 'set style arrow 101 lw 0.2 nohead lt rgb "#000000"'; crlf.
	
	left to: right by: stepSize do: [ :x | self plotLineSegmentFrom: x @ top to: x @ bottom extra: 'notitle arrowstyle 101'].
	top to: bottom by: stepSize do: [ :y | self plotLineSegmentFrom: left @ y to: right @ y extra: 'nohead lt rgb "#000000" notitle'].
	"left to: right by: stepSize do: [ :x | self plotLineSegmentFrom: x @ top to: x @ bottom extra: 'nohead lt rgb ''#000000'' notitle lw 1' ].
	top to: bottom by: stepSize do: [ :y | self plotLineSegmentFrom: left @ y to: right @ y extra: 'nohead lt rgb ''#000000'' notitle lw 1' ]."

]

{ #category : #'plotting - helper' }
VMPlotter >> plotGridFrom: pointA to: pointB by: stepSize color: aColor [
	| top bottom left right |
	left := pointA x min: pointB x.
	right := pointA x max: pointB x.
	top := pointA y min: pointB y.
	bottom := pointA y max: pointB y.
	
	"plotInitStream
		nextPutAll: 'set style arrow 101 lw 0.2 nohead lt rgb ''#000000'''; crlf.
	
	left to: right by: stepSize do: [ :x | self plotLineSegmentFrom: x @ top to: x @ bottom extra: 'notitle arrowstyle 101']."
	left to: right by: stepSize do: [ :x | self plotLineSegmentFrom: x @ top to: x @ bottom extra: 'nohead lt rgb "#', aColor asHexString, '" notitle'].
	top to: bottom by: stepSize do: [ :y | self plotLineSegmentFrom: left @ y to: right @ y extra: 'nohead lt rgb "#', aColor asHexString, '" notitle'].

]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotHeadlessArrowCollection2: aCollection [
	"note: only renders obstacles"
	| dataID |
	
	dataID := self createDataID. 
	
	autoColor ifTrue: [
		plotInitStream	
			nextPutAll: 'set style arrow 101 lt 1 lc rgb "black" nohead lw ', lineWidth printString, crlf.].
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2:3:4:5 with vectors arrowstyle var';
		nextPutAll: ' t '''''.

	aCollection doWithIndex: [ :vec :index |
		vec type isObstacle ifTrue: [
		plotData
			nextPutAll: vec pointA x printString;
			nextPutAll: ' ';
			nextPutAll: vec pointA y printString;
			nextPutAll: ' ';
			nextPutAll: vec direction x printString;
			nextPutAll: ' ';
			nextPutAll: vec direction y printString;
			nextPutAll: ' ';
			nextPutAll: '101';
			nextPutAll: crlf.].].
	
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotHeadlessArrowCollection3: aCollection [
	autoColor ifTrue: [
		plotInitStream	
			nextPutAll: 'set style arrow 101 lt 1 lc rgb "black" nohead lw ', lineWidth printString, crlf;
			nextPutAll: 'set style arrow 2 lt 1 lc rgb "green" nohead lw ', lineWidth printString, crlf;
			nextPutAll: 'set style arrow 3 lt 1 lc rgb "#CAA300" nohead lw ', lineWidth printString, crlf.].
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2:3:4:5 with vectors arrowstyle var';
		nextPutAll: ' t '''''.

	aCollection doWithIndex: [ :vec :index |
		plotData
			nextPutAll: vec pointA x printString;
			nextPutAll: ' ';
			nextPutAll: vec pointA y printString;
			nextPutAll: ' ';
			nextPutAll: vec direction x printString;
			nextPutAll: ' ';
			nextPutAll: vec direction y printString;
			nextPutAll: ' ';
			nextPutAll: (vec type isObstacle ifTrue: ['101'] ifFalse: [vec type asInteger printString]);
			nextPutAll: crlf.].
	
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotHeadlessArrowCollection: aCollection [
	| dataID |
	
	dataID := self createDataID. 
	
	autoColor ifTrue: [
		plotInitStream	
			nextPutAll: 'set style arrow 1 lt 1 lc rgb "red" nohead lw ', lineWidth printString, crlf;
			nextPutAll: 'set style arrow 2 lt 1 lc rgb "green" nohead lw ', lineWidth printString, crlf;
			nextPutAll: 'set style arrow 3 lt 1 lc rgb "#FFCAA300" nohead lw ', lineWidth printString, crlf.
	].
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2:3:4:5 with vectors arrowstyle var';
		nextPutAll: ' t '''''.

	aCollection doWithIndex: [ :vec :index |
		plotData
			nextPutAll: vec pointA x printString;
			nextPutAll: ' ';
			nextPutAll: vec pointA y printString;
			nextPutAll: ' ';
			nextPutAll: vec direction x printString;
			nextPutAll: ' ';
			nextPutAll: vec direction y printString;
			nextPutAll: ' ';
			nextPutAll: vec type asInteger printString;
			nextPutAll: crlf.
	].
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - execution' }
VMPlotter >> plotInit [
	| cmd process |
	cmd := {'/usr/bin/gnuplot'. '-p'}.
	
	process := SystemProcess  new.
	process redirectStdin.
	process onFinishDo: [ process cleanup  ].
	process shellCommand: cmd.
	
	^process
]

{ #category : #accessing }
VMPlotter >> plotInitStream [
	^ plotInitStream
]

{ #category : #'plotting - helper - text' }
VMPlotter >> plotLabel: aString at: aPoint [
	labelCounter := labelCounter + 1.
	plotInitStream
		nextPutAll: 'set label front';
		crlf;
		nextPutAll: 'set label ', labelCounter printString, ' at ', aPoint x printString, ', ', aPoint y printString;
		crlf;
		nextPutAll: 'set label ', labelCounter printString, ' "', aString ,'" tc rgb "#000000"';
		crlf.
]

{ #category : #'plotting - helper - text' }
VMPlotter >> plotLabel: aString at: aPoint color: aColor [
	labelCounter := labelCounter + 1.
	plotInitStream
		nextPutAll: 'set label front';
		crlf;
		nextPutAll: 'set label ', labelCounter printString, ' at ', aPoint x printString, ', ', aPoint y printString;
		crlf;
		nextPutAll: 'set label ', labelCounter printString, ' "', aString ,'" tc rgb "#', aColor asHexString, '"';
		crlf.
]

{ #category : #'plotting - helper' }
VMPlotter >> plotLasers: aPointCloud [
	| centerPoint centerString |
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', "" ' ]);
		nextPutAll: 'using 1:2:3:4 with vectors nohead lt rgb "#FF9090"';
		nextPutAll: ' notitle'.
	
	centerPoint := aPointCloud sensorCenter.
	centerString := aPointCloud sensorCenter x printString, ' ', aPointCloud sensorCenter y printString, ' '.
	aPointCloud points do: [ :aPoint |
		| delta |
		delta := aPoint - centerPoint.
		plotData
			nextPutAll: centerString;
			nextPutAll: delta x printString;
			nextPutAll: ' ';
			nextPutAll: delta y printString;
			nextPutAll: crlf.
	].
	plotData nextPutAll: 'e'; crlf.
	
]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotLineSegment: aVMLineSegment [
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2:3:4 with vectors nohead lt rgb "#000000"';
		nextPutAll: ' notitle'.
	
	plotData
		nextPutAll: aVMLineSegment pointA x printString;
		nextPutAll: ' ';
		nextPutAll: aVMLineSegment pointA y printString;
		nextPutAll: ' ';
		nextPutAll: aVMLineSegment direction x printString;
		nextPutAll: ' ';
		nextPutAll: aVMLineSegment direction y printString;
		nextPutAll: crlf;
		nextPutAll: 'e'; crlf.
	
]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotLineSegment: aVMLineSegment extra: extraString [
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2:3:4 with vectors ';
		nextPutAll: extraString.
		"nextPutAll: 'using 1:2:3:4 with vectors nohead lt rgb #000000';
		nextPutAll: ' notitle'."
	
	plotData
		nextPutAll: aVMLineSegment pointA x printString;
		nextPutAll: ' ';
		nextPutAll: aVMLineSegment pointA y printString;
		nextPutAll: ' ';
		nextPutAll: aVMLineSegment direction x printString;
		nextPutAll: ' ';
		nextPutAll: aVMLineSegment direction y printString;
		nextPutAll: crlf;
		nextPutAll: '# line=', aVMLineSegment printString;
		nextPutAll: crlf;
		nextPutAll: 'e'; crlf.
	
]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotLineSegmentFrom: pointA to: pointB extra: extraString [
	| direction |
	
	direction := pointB - pointA.

	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2:3:4 with vectors ';
		nextPutAll: extraString.
	
	plotData
		nextPutAll: pointA x printString;
		nextPutAll: ' ';
		nextPutAll: pointA y printString;
		nextPutAll: ' ';
		nextPutAll: direction x printString;
		nextPutAll: ' ';
		nextPutAll: direction y printString;
		nextPutAll: crlf;
		nextPutAll: 'e'; crlf.
	
]

{ #category : #'plotting - helper' }
VMPlotter >> plotLines: aCollection extra: extraString [
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', "" ' ]);
		nextPutAll: 'using 1:2 with line ';
		nextPutAll: extraString.
	
	aCollection do: [ :aPoint |
		plotData
			nextPutAll: aPoint x printString;
			nextPutAll: ' ';
			nextPutAll: aPoint y printString;
			nextPutAll: crlf.
	].
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #plotting }
VMPlotter >> plotOn: process [
	"self subclassResponsibility."
]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotOn: aSubProcess arrowCollection2: aCollection [
	| inStream |
	inStream := aSubProcess stdinStream.
	
	"inStream
		nextPutAll: 'plot ''-'' using 1:2 with lines ';
		nextPutAll: ' t ''''';
		nextPutAll: crlf."

	aCollection do: [ :vec |
		"set arrow from 0,0 to 1,1"
		inStream
			nextPutAll: 'set arrow from ';
			nextPutAll: vec pointA x printString;
			nextPutAll: ',';
			nextPutAll: vec pointA y printString;
			nextPutAll: ' to ';
			nextPutAll: vec pointB x printString;
			nextPutAll: ',';
			nextPutAll: vec pointB y printString;
			nextPutAll: crlf.
	].

]

{ #category : #'plotting - helper' }
VMPlotter >> plotPointCollection: aCollection [
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', "" ' ]);
		nextPutAll: 'using 1:2 with points pointtype 7 pointsize 0.33';
		nextPutAll: ' t '''''. "empty title"
	
	aCollection do: [ :aPoint |
		plotData
			nextPutAll: aPoint x printString;
			nextPutAll: ' ';
			nextPutAll: aPoint y printString;
			nextPutAll: crlf.
	].
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - helper' }
VMPlotter >> plotPointCollection: aCollection color: aColor [
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', "" ' ]);
		nextPutAll: 'using 1:2 with points pointtype 7 pointsize 0.33';
		nextPutAll: ' lt rgb "#', aColor asHexString, '"';
		nextPutAll: ' t '''''. "empty title"
	
	aCollection do: [ :aPoint |
		plotData
			nextPutAll: aPoint x printString;
			nextPutAll: ' ';
			nextPutAll: aPoint y printString;
			nextPutAll: crlf.
	].
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - helper' }
VMPlotter >> plotPointCollection: aCollection extra: extraString [
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', "" ' ]);
		nextPutAll: 'using 1:2 with points ';
		nextPutAll: extraString.
	
	aCollection do: [ :aPoint |
		plotData
			nextPutAll: aPoint x printString;
			nextPutAll: ' ';
			nextPutAll: aPoint y printString;
			nextPutAll: crlf.
	].
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotPolygonsIntelOffline: offline from: startIndex to: endIndex by: stepSize [
	startIndex to: endIndex by: stepSize do: [ :index |
		self plotFilledPolygon: ((offline simplePolygonAt: index) transform: (offline icpTF at: (index-startIndex+1))) extra: 'lc rgb "#FFFFFF"'.
	].
]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotPolygonsOffline: offline from: startIndex to: endIndex by: stepSize [
	startIndex to: endIndex by: stepSize do: [ :index |
		self plotFilledPolygon: ((offline simplePolygonAt: index) transform: (offline icpTF at: (index-startIndex/2+1))) extra: 'lc rgb "#FFFFFF"'.
	].
]

{ #category : #'plotting - helper' }
VMPlotter >> plotPoseCollection: aCollection [
	^ self plotPoseCollection: aCollection color: Color cyan
]

{ #category : #'plotting - helper' }
VMPlotter >> plotPoseCollection: aCollection color: aColor [
	^ self plotPoseCollection: aCollection color: aColor pointSize: 0.15

]

{ #category : #'plotting - helper' }
VMPlotter >> plotPoseCollection: aCollection color: aColor pointSize: pointSizeFloat [
	| points |
	
	points := aCollection collect: [ :tf |
		tf translate asPoint.
	].
	
	self plotPointCollection: points extra: 'pointtype 7 pointsize ', pointSizeFloat printString, ' lt rgb "#', aColor asHexString, '" notitle'.

]

{ #category : #'plotting - helper' }
VMPlotter >> plotPoseCollection: aCollection rainbowFrom: hueStart to: hueEnd [
	| hueStepSize hue |
	
	hueStepSize := hueEnd - hueStart / (aCollection size - 1).
	hue := hueStart.
	
	aCollection do: [ :tfPose |
		tfPose ifNotNil: [
			self plotPoseCollection: {tfPose} color: (Color h: hue s: 1.0 v: 1.0 ).
			hue := hue + hueStepSize.
		].
	].

]

{ #category : #'plotting - helper' }
VMPlotter >> plotPoseCollection: aCollection rainbowFrom: hueStart to: hueEnd pointSize: pointSizeFloat [
	| hueStepSize hue |
	
	hueStepSize := hueEnd - hueStart / (aCollection size - 1).
	hue := hueStart.
	
	aCollection do: [ :tfPose |
		tfPose ifNotNil: [
			self plotPoseCollection: {tfPose} color: (Color h: hue s: 1.0 v: 1.0 ) pointSize: pointSizeFloat.
			hue := hue + hueStepSize.
		].
	].

]

{ #category : #'plotting - helper' }
VMPlotter >> plotPoseIndicesCollection: aCollection by: stepSize [
	| offset |
	offset := -0.3 @ 1.0.
	1 to: aCollection size by: stepSize do: [ :index |
		| point offsetPoint offsetPoint2 |
		point := (aCollection at: index) translate asPoint.
		offsetPoint := point + offset.
		offsetPoint2 := point + ( 0.8 * offset) + (0.3@0).
		
		self plotPointCollection: {point} extra: 'pointtype 7 pointsize 0.3 lt rgb "#000000" notitle'.
		self plotLineSegmentFrom: offsetPoint2 to: point extra: 'lc rgb "#0000FF" notitle'.
		self plotLabel: index printString at: offsetPoint color: Color blue.
	].

]

{ #category : #'plotting - helper' }
VMPlotter >> plotRobotAt: center angle: theta radius: radius [
	| angle steps deltaAngle radius2 width |
	
	angle := theta.
	steps := 20.
	deltaAngle := Float twoPi / steps.
	objectCounter := objectCounter + 1.
	radius2 := radius * 0.92.
	
	plotInitStream
		nextPutAll: 'set object ';
		nextPutAll: objectCounter printString;
		nextPutAll: ' polygon front from '.
	
	"create outer circle"
	1 to: steps do: [ :i |
		plotInitStream
			nextPutAll: (center x + (angle cos * radius)) printString;
			nextPutAll: ', ';
			nextPutAll: (center y + (angle sin * radius)) printString;
			nextPutAll: ' to '.
		angle := angle + deltaAngle.
	].
	plotInitStream
		nextPutAll: (center x + (angle cos * radius)) printString;
		nextPutAll: ', ';
		nextPutAll: (center y + (angle sin * radius)) printString;
		nextPutAll: ' to '.
	"inner circle"
	1 to: steps do: [ :i |
		plotInitStream
			nextPutAll: (center x + (angle cos * radius2)) printString;
			nextPutAll: ', ';
			nextPutAll: (center y + (angle sin * radius2)) printString;
			nextPutAll: ' to '.
		angle := angle - deltaAngle.
	].
	plotInitStream
		nextPutAll: (center x + (angle cos * radius2)) printString;
		nextPutAll: ', ';
		nextPutAll: (center y + (angle sin * radius2)) printString;
		nextPutAll: crlf.
	plotInitStream
		nextPutAll: crlf.
	plotInitStream
		nextPutAll: 'set object ';
		nextPutAll: objectCounter printString;
		nextPutAll: ' fc rgb "#000000" fillstyle solid lw 0';
		nextPutAll: crlf.
	
	"create orientation marker"
	objectCounter := objectCounter + 1.
	plotInitStream
		nextPutAll: 'set object ';
		nextPutAll: objectCounter printString;
		nextPutAll: ' polygon front from '.
	
	angle := theta-(Float twoPi / 72).
	deltaAngle := Float twoPi / 36.
	width := ((Float twoPi / 72) sin * radius*0.98) abs.
	plotInitStream
		nextPutAll: (center x + (angle cos * radius*0.98)) printString;
		nextPutAll: ', ';
		nextPutAll: (center y + (angle sin * radius*0.98)) printString;
		nextPutAll: ' to '.
	angle := angle + deltaAngle.
	plotInitStream
		nextPutAll: (center x + (angle cos * radius*0.98)) printString;
		nextPutAll: ', ';
		nextPutAll: (center y + (angle sin * radius*0.98)) printString;
		nextPutAll: ' to '.
	angle := theta - Float halfPi.
	plotInitStream
		nextPutAll: (center x - (angle cos * width)) printString;
		nextPutAll: ', ';
		nextPutAll: (center y - (angle sin * width)) printString;
		nextPutAll: ' to '.
	angle := theta + Float halfPi.
	plotInitStream
		nextPutAll: (center x - (angle cos * width)) printString;
		nextPutAll: ', ';
		nextPutAll: (center y - (angle sin * width)) printString;
		nextPutAll: crlf.
	
	
	plotInitStream
		nextPutAll: 'set object ';
		nextPutAll: objectCounter printString;
		nextPutAll: ' fc rgb "#000000" fillstyle solid lw 0';
		nextPutAll: crlf.
	

]

{ #category : #'plotting - helper' }
VMPlotter >> plotSensor: aVMTFMatrix [
	"using a matrix instead of a point, because a point doesn't have an orientation"
	| aPoint |
	
	aPoint := aVMTFMatrix translate asPoint.
	
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', "" ' ]);
		nextPutAll: 'using 1:2 with points pointtype 6 pointsize 1 ';
		nextPutAll: ' lt rgb "#', Color blue asHexString, '"';
		nextPutAll: ' t '''''. "empty title"
	
	plotData
		nextPutAll: aPoint x printString;
		nextPutAll: ' ';
		nextPutAll: aPoint y printString;
		nextPutAll: crlf.
	plotData nextPutAll: 'e'; crlf.
	

]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotter >> plotVectorCollection: aCollection [
	plotCmd
		nextPutAll: (plotCmd isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2 with with lines ';
		nextPutAll: ' t ''''';
		nextPutAll: crlf.
	
	aCollection do: [ :vec |
		plotData
			nextPutAll: vec pointA x printString;
			nextPutAll: ' ';
			nextPutAll: vec pointA y printString;
			nextPutAll: crlf.
	].
	plotData nextPutAll: 'e'; crlf.

]

{ #category : #printing }
VMPlotter >> printDebug [
	Transcript
		show: '>>> gnuplot stream:';
		cr;
		show: plotInitStream contents;
		"show: plotDataStream contents;"
		show: plotCmd contents;
		cr;
		show: plotData contents;
		cr; cr.
]

{ #category : #accessing }
VMPlotter >> range [
	^range
]

{ #category : #accessing }
VMPlotter >> range: aRectangle [
	range := aRectangle.
	
	plotInitStream
		nextPutAll: 'set xrange [', range left printString,':', range right printString,']'; crlf;
		nextPutAll: 'set yrange [', range top printString,':', range bottom printString,']'; crlf.

]

{ #category : #accessing }
VMPlotter >> setRatio: aNumber [
	plotInitStream
		nextPutAll: 'set size ratio ';
		nextPutAll: aNumber printString;
		nextPutAll: crlf.
]

{ #category : #initialization }
VMPlotter >> setTerminal: terminal [
	"sets the terminal (render backend) to the provided settings.
	this command only makes sense if there's no need to specify the output filename.
	example:
		(VMPlotter new)
			range: (Rectangle point: 0@0 point: 10@10);
			setRatio: -1;
			plotHeadlessArrowCollection: {VMLineSegment from: 2@2 to: 2@5. VMLineSegment from: 2@5 to: 8@8. };
			setTerminal: 'qt size 1000,1000 enhanced';
			plot.
	"
	plotInitStream
		nextPutAll: 'set terminal ', terminal;
		nextPutAll: crlf.

]

{ #category : #initialization }
VMPlotter >> setTerminal: terminal filename: filename [
	"sets the terminal (render backend) to the provided settings.
	example:
		(VMPlotter new)
			range: (Rectangle point: 0@0 point: 10@10);
			setRatio: -1;
			plotHeadlessArrowCollection: {VMLineSegment from: 2@2 to: 2@5. VMLineSegment from: 2@5 to: 8@8. };
			setTerminal: 'eps size 5.0,8.0 enhanced' filename: '/opt/shared/imt_git/plots/test.eps';
			plot.
	"
	plotInitStream
		nextPutAll: 'set terminal ', terminal;
		nextPutAll: crlf;
		nextPutAll: 'set output "', filename, '"';
		nextPutAll: crlf.
]

{ #category : #'plotting - helper - text' }
VMPlotter >> title: aString [
	plotInitStream
		nextPutAll: 'set title "';
		nextPutAll: aString;
		nextPutAll: '"';
		crlf.
]
