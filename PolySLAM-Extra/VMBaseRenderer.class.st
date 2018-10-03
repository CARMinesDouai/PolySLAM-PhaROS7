Class {
	#name : #VMBaseRenderer,
	#superclass : #Object,
	#instVars : [
		'model',
		'color',
		'label',
		'lineWidth',
		'dashStyle'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMBaseRenderer class >> model: aModel [
	^(self new)
		model: aModel;
		yourself.
]

{ #category : #'as yet unclassified' }
VMBaseRenderer >> applyStyleTo: anObject [
	"set the basic render style options of 'anObject' to the same values as self"
	anObject color: color.
	anObject label: label.
	anObject lineWidth: lineWidth.
	anObject dashStyle: dashStyle.
]

{ #category : #converting }
VMBaseRenderer >> asRenderableElement [
	^self.
]

{ #category : #accessing }
VMBaseRenderer >> bounds [
	"expected to return a Rectangle that represents the boundaries of the model.
	if the object has no rectangle, nil should be returned"
	
	model ifNotNil: [ ^model bounds ].
	
	^ nil
]

{ #category : #accessing }
VMBaseRenderer >> boundsForCollection: aCollection [
	| rect |
	
	rect := nil.
	aCollection do: [ :obj |
		(obj respondsTo: #bounds)
			ifTrue:[ rect
				ifNil: [ rect := obj bounds. ]
				ifNotNil: [ rect := rect merge: obj bounds. ]
			].
	].
	
	^ rect

]

{ #category : #accessing }
VMBaseRenderer >> collectionBounds: aCollection [
	"expected to return a Rectangle that represents the boundaries of the model"
	| bounds |
	
	aCollection ifEmpty: [ ^ nil ].
	
	bounds := aCollection first bounds.
	
	aCollection allButFirstDo: [ :element |
		bounds := bounds merge: element bounds
	].
	
	^bounds
]

{ #category : #accessing }
VMBaseRenderer >> color [
	^color

]

{ #category : #accessing }
VMBaseRenderer >> color: aColor [
	color := aColor.

]

{ #category : #'as yet unclassified' }
VMBaseRenderer >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
]

{ #category : #initialization }
VMBaseRenderer >> initialize [
	super initialize.
	color := Color magenta.
	label := ''.
	"font := LogicalFont familyName: 'Arial' pointSize: 20.
	textScale := 0.05."
	lineWidth := 0.05.

]

{ #category : #accessing }
VMBaseRenderer >> label [
	^label
	
]

{ #category : #accessing }
VMBaseRenderer >> label: aString [
	label := aString.

	
]

{ #category : #accessing }
VMBaseRenderer >> labelPosition [
	self subclassResponsibility.
]

{ #category : #'rendering - lines' }
VMBaseRenderer >> lineFactorsFrom: fromPoint to: toPoint rect: rect [
	| direction factorStart factorEnd |
	
	direction := toPoint - fromPoint.
	
	(direction x abs > direction y abs)
		ifTrue: [
			"compute the point that crosses the left & right border"
			factorStart := (rect origin x - fromPoint x) / direction x.
			factorEnd := (rect corner x - fromPoint x) / direction x.
		]
		ifFalse: [
			"compute the point that crosses the top & bottom border"
			factorStart := ((rect origin y - fromPoint y) / direction y) negated.
			factorEnd := ((rect corner y - fromPoint y) / direction y) negated.
		].
	
	^{factorStart.  factorEnd}.

]

{ #category : #'rendering - lines' }
VMBaseRenderer >> linePointsFrom: fromPoint to: toPoint rect: rect [
	| factors startPoint endPoint direction |
	
	direction := toPoint - fromPoint.
	
	factors := self lineFactorsFrom: fromPoint to: toPoint rect: rect.
	
	startPoint := fromPoint + (direction * factors first * 2).
	endPoint := fromPoint + (direction * factors second * 2).
	
	^{startPoint.  endPoint}.

]

{ #category : #accessing }
VMBaseRenderer >> lineWidth [
	^lineWidth.

]

{ #category : #accessing }
VMBaseRenderer >> lineWidth: aNumber [
	lineWidth := aNumber.

]

{ #category : #accessing }
VMBaseRenderer >> model [
	^model
	
]

{ #category : #accessing }
VMBaseRenderer >> model: anObject [
	model := anObject.
]

{ #category : #'rendering - lines' }
VMBaseRenderer >> rayPointsFrom: fromPoint to: toPoint rect: rect [
	| factors endPointFactor direction |
	
	direction := toPoint - fromPoint.
	
	factors := self lineFactorsFrom: fromPoint to: toPoint rect: rect.
	endPointFactor := (factors second < 1)
		ifTrue: [ 1.0 ]
		ifFalse: [ factors second].
	
	^{fromPoint.  fromPoint + (direction * endPointFactor)}.

]

{ #category : #'rendering - lines' }
VMBaseRenderer >> renderArrow: lineSeg on: aCanvas [
	| style |
	style := dashStyle.
	"dashStyle := { 3 * lineWidth. 2 * lineWidth }."
	"1 haltOnce."
	self renderStyledLineSegFrom: lineSeg pointA to: lineSeg pointB on: aCanvas color: lineSeg type renderColor.
	"dashStyle := style."
	self renderArrowHeadFrom: lineSeg pointA to: lineSeg pointB on: aCanvas color: lineSeg type renderColor.
]

{ #category : #'rendering - lines' }
VMBaseRenderer >> renderArrow: lineSeg on: aCanvas color: aColor [
	self renderStyledLineSegFrom: lineSeg pointA to: lineSeg pointB on: aCanvas color: aColor.
	self renderArrowHeadFrom: lineSeg pointA to: lineSeg pointB on: aCanvas color: aColor.
]

{ #category : #'rendering - lines' }
VMBaseRenderer >> renderArrowHeadFrom: fromPoint to: toPoint on: aCanvas color: aColor [
	"renders a arrow head with the tip at 'toPoint'. the length of the arrow head
	is computed as '6 * lineWidth', capped to be never longer than the distance
	'fromPoint dist: toPoint'."
	| stroke arrowPath lineLength arrowWidth arrowLength lineVector lineNormal maxArrowLength |
	
	aCanvas setPaint: aColor.
	stroke := aCanvas setStrokePaint: aColor.
	stroke width: self lineWidth.

	lineLength := fromPoint dist: toPoint.
	
	lineLength strictlyPositive ifFalse: [ ^self ].
	
	maxArrowLength := lineLength.
	
	arrowWidth := self lineWidth * 3.
	arrowLength:= self lineWidth * 6.
	
	arrowLength > maxArrowLength ifTrue: [
		| factor |
		factor := maxArrowLength / arrowLength.
		arrowLength := arrowLength * factor.
		arrowWidth := arrowWidth * factor.
	].
	
	lineVector := ((fromPoint - toPoint) normalized) * arrowLength.
	lineNormal := lineVector normal * arrowWidth.

	arrowPath := aCanvas createPath: [ :pathBuilder |
		pathBuilder absolute ;
			moveTo: (toPoint + lineVector + lineNormal) flipY;
			lineTo: toPoint flipY;
			lineTo: (toPoint + lineVector - lineNormal) flipY
	].
	aCanvas drawShape: arrowPath.


	
	

]

{ #category : #rendering }
VMBaseRenderer >> renderFilledPoint: centerPoint radius: radius on: aCanvas color: aColor [
		
	| cp top bottom path stroke |
	
	cp := centerPoint flipY.
	
	top := cp + (radius @0).
	bottom := cp - (radius @0).
	
	aCanvas setPaint: aColor.
	
	path := aCanvas createPath: [ :builder |
		builder 
			absolute; 
			moveTo: top;
			cwArcTo: bottom angle: Float pi;
			cwArcTo: top angle: Float pi.
	].

	stroke := aCanvas setStrokePaint: aColor.
	stroke width: self lineWidth.
	aCanvas drawShape: path.

]

{ #category : #'rendering - lines' }
VMBaseRenderer >> renderFilledPolygonOn: aCanvas collection: aCollection color: aColor [
	| path |
	
	(aCollection size <= 2) ifTrue: [ ^self ].
	
	aCanvas setPaint: aColor.

	path := aCanvas createPath: [ :pathBuilder |
		pathBuilder absolute;
			moveTo: aCollection last flipY.
		
		aCollection do: [ :aPoint |
			pathBuilder lineTo: aPoint flipY.
		].
	].
		
	aCanvas drawShape: path.
	
	

	
	
	
]

{ #category : #'rendering - lines' }
VMBaseRenderer >> renderFilledPolygonOn: aCanvas lineSegments: aCollection color: aColor [
	"this method assumes that the line segments are all connected. otherwise filling the area would not make sense"
	| path |
	
	(aCollection size <= 2) ifTrue: [ ^self ].
	
	aCanvas setPaint: aColor.

	path := aCanvas createPath: [ :pathBuilder |
		pathBuilder absolute;
			moveTo: aCollection first pointA flipY.
		
		aCollection do: [ :aLineSeg |
			pathBuilder lineTo: aLineSeg pointB flipY.
		].
	].
		
	aCanvas drawShape: path.
	
	

	
	
	
]

{ #category : #rendering }
VMBaseRenderer >> renderLabelOn: aCanvas [
	self renderString: self label at: self labelPosition in: aCanvas

]

{ #category : #rendering }
VMBaseRenderer >> renderOn: aCanvas viewer: aVMViewer [
	self renderOn: aCanvas
]

{ #category : #rendering }
VMBaseRenderer >> renderPoint: centerPoint radius: radius on: aCanvas color: aColor [
		
	| cp top bottom path stroke |
	
	cp := centerPoint flipY.
	
	top := cp + (radius @0).
	bottom := cp - (radius @0).
	
	path := aCanvas createPath: [ :builder |
		builder 
			absolute; 
			moveTo: top;
			cwArcTo: bottom angle: Float pi;
			cwArcTo: top angle: Float pi.
	].

	stroke := aCanvas setStrokePaint: aColor.
	stroke width: self lineWidth.
	aCanvas drawShape: path.

]

{ #category : #'rendering - lines' }
VMBaseRenderer >> renderRectCanvas: aCanvas [
	"returns a rectangle of the render area, transformed into the rendering frame"
	| clipRect transform |
	
	clipRect := aCanvas clipRect. "clipping rectangle, origin is 0@0"
	transform := aCanvas pathTransform.
	
	^VMRectangle
		origin: (transform inverseTransform: clipRect origin)
		corner: (transform inverseTransform: clipRect corner).
	
]

{ #category : #'rendering - lines' }
VMBaseRenderer >> renderStyledLineFrom: fromPoint to: toPoint on: aCanvas color: aColor [
	"renders a line (not line segment) by computing the visible segment of the line, and then rendering that segment"
	| startStop rect |
	
	rect := self renderRectCanvas: aCanvas.
	startStop := self linePointsFrom: fromPoint to: toPoint rect: rect.
	
	"Transcript
		show: 'rect origin=', rect origin printString, ', corner=', rect corner printString;
		cr;
		show: 'start=', startStop first printString, ', stop=', startStop second printString;
		cr."
	
	self renderStyledLineSegFrom: startStop first to: startStop second on: aCanvas color: aColor.
	

]

{ #category : #'rendering - lines' }
VMBaseRenderer >> renderStyledLineSegFrom: fromPoint to: toPoint on: aCanvas color: aColor [
	| path stroke |
	
	((fromPoint dist: toPoint) < 0.0000000001) ifTrue: [ ^self ].
	
	aCanvas setPaint: aColor.
	stroke := aCanvas setStrokePaint: aColor.
	stroke width: self lineWidth.

	self showArrowHead ifTrue: [
		self renderArrowHeadFrom: fromPoint to: toPoint on: aCanvas color: aColor.
	].

	path := aCanvas createPath: [ :pathBuilder |
		pathBuilder absolute; 
			moveTo: fromPoint flipY;
			lineTo: toPoint flipY.
	].
		
	dashStyle ifNotNil: [
		stroke dashes: dashStyle offset: 0.
	].
	
	aCanvas drawShape: path.
	
	

	
	
	
]

{ #category : #'rendering - lines' }
VMBaseRenderer >> renderStyledRayFrom: fromPoint to: toPoint on: aCanvas color: aColor [
	"renders a line (not line segment) by computing the visible segment of the line, and then rendering that segment"
	| startStop rect |
	
	rect := self renderRectCanvas: aCanvas.
	startStop := self rayPointsFrom: fromPoint to: toPoint rect: rect.
	
	"Transcript
		show: 'rect origin=', rect origin printString, ', corner=', rect corner printString;
		cr;
		show: 'start=', startStop first printString, ', stop=', startStop second printString;
		cr."
	
	self renderStyledLineSegFrom: startStop first to: startStop second on: aCanvas color: aColor.
	

]

{ #category : #accessing }
VMBaseRenderer >> showArrowHead [
	^false.
]

{ #category : #'as yet unclassified' }
VMBaseRenderer >> viewport: aCanvas [
	"returns a rectangle containg the coordinate boundaries of the visible area in absolute
	coorinates (i.e. the coordinate of the renderable elements, not pixel coordinates)"
	| rect transform |
	
	"rectangle that is drawn to in canvas coordinates (i.e. 1@1 extent: width@height)"
	rect :=  1 @ 1 extent: aCanvas surface extent.
	
	"transformation matrix (object -> canvas coordinates)"
	transform := aCanvas pathTransform.
	
	^Rectangle origin: (transform inverseTransform: 1@1) corner: (transform inverseTransform: rect corner)
]
