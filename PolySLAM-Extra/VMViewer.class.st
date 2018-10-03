"
Viewer for visualization and debugging.


Key messages:

  - add: <anElement>
	adds 'anElement' to the list of elements that are rendered in the viewer
- addAll: <aCollection>
	calls #add: for each element in the collection
- removeAll
	removes all elements from the internal list, ending up with an empty list of elements to render
- exportAsPNG: <aString>
	exports the current viewport of the viewer as a PNG image, using 'aString' as location (filename, including path)
- zoomFactor: <aNumber> at: <aPoint>
	zooms to the provided factor at the provided location
- panTo: <aPoint>
	translates the viewport according to the provided point


Note:  The unit used when rendering is meter, so a line width of 0.2 for example is equal to 20cm.


Example usage >>>>>

line := VMLine pointA: 0@0 pointB: 10@10.
rLine := (VMLineRenderer model: line) lineWidth: 0.25; color: Color red yourself.

ray := VMRay pointA: 20@20 pointB: 30@18.
rRay := (VMRayRenderer model: ray) lineWidth: 0.25; color: Color blue; yourself.

lineSeg := VMLineSegment pointA: 60@60 pointB: (ray pointA + (ray direction * 4.5)).
rLineSeg := (VMLineSegRenderer model: lineSeg) lineWidth: 0.25; color: Color green; yourself.

viewer := VMViewer openOn: { rLine.  rRay }.
viewer add: rLineSeg.
viewer zoomFactor: 4 at: 0@0; panTo: -20@300.

<<<<< end of example
"
Class {
	#name : #VMViewer,
	#superclass : #AthensInteractiveScene,
	#instVars : [
		'elementCollection',
		'backgroundColor',
		'myMinExtent',
		'showDebugText',
		'grid',
		'labels'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMViewer class >> defaultMinExtent [
	^ 600@600
]

{ #category : #'as yet unclassified' }
VMViewer class >> openOn: aCollection [

	^ self basicNew
		initialize;
		openInWindow;
		addAll: aCollection;
		yourself
]

{ #category : #'as yet unclassified' }
VMViewer class >> openOn: aCollection extent: newSize [

	^ self basicNew
		myMinExtent: newSize;
		initialize;
		openInWindow;
		addAll: aCollection;
		yourself
]

{ #category : #'as yet unclassified' }
VMViewer class >> openWindowlessOn: aCollection [

	^ self basicNew
		initialize;
		addAll: aCollection;
		yourself
]

{ #category : #adding }
VMViewer >> add: anObj [
	elementCollection add: anObj.
	self changed.
]

{ #category : #adding }
VMViewer >> addAll: aCollection [
	elementCollection addAll: aCollection.
	"self changed"
]

{ #category : #'as yet unclassified' }
VMViewer >> autozoom [
	| viewerRect objBounds objCenter sX sY scaleFactor |
	
	"size of the underlaying morph"
	viewerRect := Rectangle origin: 0@0 corner: self extent.
	
	"bounds of the objects that are part of the scene"
	objBounds := self sceneBounds. 
	
	sX := objBounds width = 0 ifTrue: [ 1 ] ifFalse: [ viewerRect width / objBounds width ].
	sY := objBounds height = 0 ifTrue: [ 1 ] ifFalse: [ viewerRect height/ objBounds height ].
	
	scaleFactor := (sX min: sY) * 0.8.
	
	objCenter := objBounds center.
	objCenter := objCenter + (viewerRect corner * (0.5 / scaleFactor)).
	
	transform loadIdentity;
		scaleBy: scaleFactor;
		translateBy: objCenter.
	
	self changed

]

{ #category : #accessing }
VMViewer >> backgroundColor [
	^backgroundColor.
]

{ #category : #accessing }
VMViewer >> backgroundColor: aColor [
	backgroundColor := aColor
]

{ #category : #'initialize-release' }
VMViewer >> close [
	owner delete.
]

{ #category : #'debug support' }
VMViewer >> debugText [
	| px py |

	px := transform x printShowingDecimalPlaces: 3.
	py := transform y printShowingDecimalPlaces: 3.

	^ ' zoom: ' , (transform sx printShowingDecimalPlaces: 3) , ' pan: ' , px , ' @ ' , py
]

{ #category : #drawing }
VMViewer >> drawOn: canvas [

	self renderScene.

	surface displayOnMorphicCanvas: canvas at: bounds origin.

"	 translucentImage: surface asForm at: bounds origin."
	
	labels do: [ :label |
		canvas
			drawString: label label
			at: bounds origin + label bounds origin
			font: nil
			color: label color
	].
	
	self showDebugInfo
		ifTrue: [ 
			| px py |
			px := transform x printShowingDecimalPlaces: 3.
			py := transform y printShowingDecimalPlaces: 3.
			canvas
				drawString: self debugText
				at: bounds origin
				font: nil
				color: Color red ]
]

{ #category : #'event handling' }
VMViewer >> eventHandledByScene: evt [

	(scene respondsTo: #handleEvent:in:at:) ifTrue: [ 
		^ super eventHandledByScene: evt
	].
	^ false
]

{ #category : #'image export' }
VMViewer >> exportAsPNG: filename [
	| fName |
	
	filename isEmptyOrNil ifTrue: [ ^self ].
	
	fName := filename, (DateAndTime now asString copyReplaceAll: ':' with: '-'), '.png'.
	
	PNGReadWriter putForm: self imageForm onFileNamed: fName.
]

{ #category : #'as yet unclassified' }
VMViewer >> hideGrid [
	grid := nil.
]

{ #category : #'initialize-release' }
VMViewer >> initialize [
	super initialize. 
	"backgroundColor := Color veryLightGray."
	backgroundColor := Color black.
	showDebugText := true.
	self showGrid.
	labels := OrderedCollection new.
	
	elementCollection := OrderedCollection new.
	
	self scene: [ :aCanvas |
		grid ifNotNil: [ grid renderOn: aCanvas ].
		elementCollection do: [ :element |
			| rObj |
			rObj := element asRenderableElement.
			(rObj respondsTo: #renderOn:viewer:)
				ifTrue: [ rObj renderOn: aCanvas viewer: self ]
				ifFalse: [ rObj renderOn: aCanvas ].
		].
	].
	
	

]

{ #category : #accessing }
VMViewer >> label: aVMLabel [
	labels add: aVMLabel.
]

{ #category : #accessing }
VMViewer >> labels [
	^ labels
]

{ #category : #adding }
VMViewer >> minimumExtent [
	^ self myMinExtent 
]

{ #category : #adding }
VMViewer >> myMinExtent [
	^ myMinExtent ifNil: [ self class defaultMinExtent ]
]

{ #category : #adding }
VMViewer >> myMinExtent: anObject [
	myMinExtent := anObject
]

{ #category : #drawing }
VMViewer >> panTo: deltaPoint [
	transform
			x: deltaPoint x;
			y: deltaPoint y.
	self changed
]

{ #category : #'as yet unclassified' }
VMViewer >> removeAll [
	elementCollection removeAll.
]

{ #category : #drawing }
VMViewer >> renderScene [

	self checkSession.

	scene ifNotNil: [ 
		surface drawDuring: [ :aCanvas | 
			surface clear: (self backgroundColor).
			aCanvas pathTransform loadAffineTransform: transform.
			scene isBlock
				ifTrue: [ scene cull: aCanvas cull: self ]
				ifFalse: [ scene renderOn: aCanvas ] ] ]
]

{ #category : #'as yet unclassified' }
VMViewer >> sceneBounds [
	"computes the scene based on the bounds of the renderable objects in the scene collection.
	if no bounds could be computed a default rectangle from -1@-1 to 1@1 will be returned."
	| objBounds |
	
	elementCollection doWithIndex: [ :obj :index |
		objBounds := obj bounds.
		objBounds ifNotNil: [
			(index + 1) to: elementCollection size do: [ :index2 |
				| rect |
				rect := (elementCollection at: index2) bounds.
				rect ifNotNil: [ objBounds := objBounds merge: rect. ].
			].
			^ objBounds
		]
	].
	
	^ -1 @ -1 extent: 2 @ 2.
	

]

{ #category : #'as yet unclassified' }
VMViewer >> showDebugInfo [
	^showDebugText
]

{ #category : #'as yet unclassified' }
VMViewer >> showDebugInfo: bool [
	showDebugText := bool
]

{ #category : #'as yet unclassified' }
VMViewer >> showGrid [
	grid := (VMGridRenderer new) color: (Color h: 82 s: 0.6 v: 1.0).
]

{ #category : #'as yet unclassified' }
VMViewer >> viewport [
	| morphSize viewRect |
	
	"size of the underlying morph drawing area"
	morphSize := self extent.
	
	"tranformed by the same transform that applies to all objects that are displayed"
	viewRect := Rectangle origin: (transform inverseTransform: 1@1) corner: (transform inverseTransform: morphSize).
	
	^viewRect.
	
	
]

{ #category : #drawing }
VMViewer >> zoomFactor: factor at: aPoint [ 
	transform
			translateBy: aPoint;
			scaleBy: factor.
	self changed
]
