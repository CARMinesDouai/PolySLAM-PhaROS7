"
I can display any VM element in a window
"
Class {
	#name : #VMMapViewer,
	#superclass : #AthensInteractiveScene,
	#instVars : [
		'myMinExtent',
		'backgroundColor'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'default constants' }
VMMapViewer class >> defaultMinExtent [
	^ 600@600
]

{ #category : #'opening view' }
VMMapViewer class >> openOn: vmElementsOrBlock [		
	^ self openOn: vmElementsOrBlock extent: self defaultMinExtent

]

{ #category : #'opening view' }
VMMapViewer class >> openOn: vmElementsOrBlock extent: size [
	|scene|
	
	scene := vmElementsOrBlock.
	
	vmElementsOrBlock isCollection ifTrue: [ 
		scene := [ :canvas |
						vmElementsOrBlock do: [ :e |
							e asRenderableElement renderOn: canvas 
						]
					]
	].
		
	^ self basicNew
		myMinExtent: size ;
		initialize;
		scene: scene;
		openInWindow;
		yourself
]

{ #category : #colors }
VMMapViewer >> backgroundColor [
	^backgroundColor.
]

{ #category : #colors }
VMMapViewer >> backgroundColor: aColor [
	backgroundColor := aColor
]

{ #category : #'debug support' }
VMMapViewer >> debugText [

	| px py |

	px := transform x printShowingDecimalPlaces: 3.
	py := transform y printShowingDecimalPlaces: 3.

	^ ' zoom: ' , (transform sx printShowingDecimalPlaces: 3) , ' pan: ' , px , ' @ ' , py
]

{ #category : #drawing }
VMMapViewer >> drawOn: canvas [

	self renderScene.

	surface displayOnMorphicCanvas: canvas at: bounds origin.

"	 translucentImage: surface asForm at: bounds origin."
	
	self showDebugInfo
		ifTrue: [ 
			| px py |
			px := transform x printShowingDecimalPlaces: 3.
			py := transform y printShowingDecimalPlaces: 3.
			canvas
				drawString: self debugText
				at: bounds origin
				font: nil
				color: Color white ]
]

{ #category : #'event handling' }
VMMapViewer >> eventHandledByScene: evt [

	(scene respondsTo: #handleEvent:in:at:) ifTrue: [ 
		^ super eventHandledByScene: evt
	].
	^ false
	
]

{ #category : #'image export' }
VMMapViewer >> exportAsPNG: filename [
	| fName |
	
	filename isEmptyOrNil ifTrue: [ ^self ].
	
	fName := filename, (DateAndTime now asString copyReplaceAll: ':' with: '-'), '.png'.
	
	PNGReadWriter putForm: self imageForm onFileNamed: fName.
]

{ #category : #'initialize-release' }
VMMapViewer >> initialize [
	super initialize.
	backgroundColor := Color black.
]

{ #category : #'initialize-release' }
VMMapViewer >> minimumExtent [
	^ self myMinExtent 
]

{ #category : #private }
VMMapViewer >> myMinExtent [
	^ myMinExtent ifNil: [ self class defaultMinExtent ]
]

{ #category : #private }
VMMapViewer >> myMinExtent: anObject [
	myMinExtent := anObject
]

{ #category : #drawing }
VMMapViewer >> panTo: deltaPoint [
	transform
			x: deltaPoint x;
			y: deltaPoint y.
	self changed
	
]

{ #category : #drawing }
VMMapViewer >> renderScene [

	self checkSession.

	scene ifNotNil: [ 
		surface drawDuring: [ :acanvas | 
			surface clear: (self backgroundColor).
			acanvas pathTransform loadAffineTransform: transform.
			scene isBlock
				ifTrue: [ scene cull: acanvas cull: self ]
				ifFalse: [ scene renderOn: acanvas ] ] ]
]

{ #category : #drawing }
VMMapViewer >> zoomFactor: factor at: aPoint [ 
	transform
			translateBy: aPoint;
			scaleBy: factor.
	self changed
]
