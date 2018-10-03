Class {
	#name : #VMFigureRenderer,
	#superclass : #VMElementRenderer,
	#instVars : [
		'showVertices',
		'showArrowHead',
		'verticeRenderer',
		'minArrowLength',
		'maxArrowLength'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #initialization }
VMFigureRenderer >> initialize [
	super initialize.
	showVertices := false.
	showArrowHead := true.
	minArrowLength := 0.001.
	maxArrowLength := 0.05.
]

{ #category : #accessing }
VMFigureRenderer >> labelPosition [
	((self points isNil) or: [self points isEmpty]) ifTrue: [ 0@0 ].
	
	^self points first.
]

{ #category : #accessing }
VMFigureRenderer >> points [
	self subclassResponsibility 
]

{ #category : #'drawing support' }
VMFigureRenderer >> renderLineCollection: aCollection color: aColor on: aCanvas [
	
	aCollection ifNil: [ ^self ].
	
	aCollection do: [ :lineSeg |
		self renderStyledLineFrom: (lineSeg pointA) to: (lineSeg pointB) in: aCanvas color: aColor.
	].
]

{ #category : #rendering }
VMFigureRenderer >> renderOn: canvas [
	
	super renderOn: canvas.
	
	self showVertices ifTrue: [ 
		|pointRenderer|
		pointRenderer := self verticeRenderer.
		self points do: [ :p | 
			pointRenderer model: p.
			pointRenderer renderOn: canvas
		]							
	]
]

{ #category : #'drawing support' }
VMFigureRenderer >> renderOn: canvas pointCollection: pointCollection color: renderColor [
	
	pointCollection ifNil: [ ^self. ].
	pointCollection ifEmpty: [ ^self. ].
	
	pointCollection do: [ :p |
		self renderPoint: p radius: lineWidth in: canvas color: renderColor.
	].

]

{ #category : #'drawing support' }
VMFigureRenderer >> renderOn: canvas pointCollection: pointCollection color: renderColor label: aString [
	
	pointCollection ifNil: [ ^self. ].
	pointCollection ifEmpty: [ ^self. ].
	
	pointCollection do: [ :p |
		self renderPoint: p radius: lineWidth in: canvas color: renderColor.
	].

	self renderString: aString at: (pointCollection first) in: canvas color: renderColor.
	

]

{ #category : #'drawing support' }
VMFigureRenderer >> renderPoint: centerPoint in: canvas [
		
	| top bottom path stroke radius |
	
	radius := lineWidth.
	top := centerPoint + (self radius@0).
	bottom := centerPoint - (self radius@0).
	
	path := canvas createPath: [ :builder |
		builder 
			absolute; 
			moveTo: top;
			cwArcTo: bottom angle: Float pi;
			cwArcTo: top angle: Float pi.
	].

	stroke := canvas setStrokePaint: self color.
	stroke width: self lineWidth.
	canvas drawShape: path.

]

{ #category : #'drawing support' }
VMFigureRenderer >> renderPoint: centerPoint radius: radius in: canvas [
		
	| top bottom path stroke |
		
	top := centerPoint + (radius@0).
	bottom := centerPoint - (radius@0).
	
	path := canvas createPath: [ :builder |
		builder 
			absolute; 
			moveTo: top;
			cwArcTo: bottom angle: Float pi;
			cwArcTo: top angle: Float pi.
	].

	stroke := canvas setStrokePaint: self color.
	stroke width: self lineWidth.
	canvas drawShape: path.

]

{ #category : #'drawing support' }
VMFigureRenderer >> renderPoint: centerPoint radius: radius in: canvas color: customColor [
		
	| top bottom path stroke |
		
	top := centerPoint + (radius @0).
	bottom := centerPoint - (radius @0).
	
	path := canvas createPath: [ :builder |
		builder 
			absolute; 
			moveTo: top;
			cwArcTo: bottom angle: Float pi;
			cwArcTo: top angle: Float pi.
	].

	stroke := canvas setStrokePaint: customColor.
	stroke width: self lineWidth.
	canvas drawShape: path.

]

{ #category : #'drawing support' }
VMFigureRenderer >> renderStyledLineFrom: fromPoint to: toPoint in: canvas [
	self renderStyledLineFrom: fromPoint to: toPoint in: canvas color: self color.

]

{ #category : #'drawing support' }
VMFigureRenderer >> renderStyledLineFrom: fromPoint to: toPoint in: canvas color: lineColor [
	| path stroke arrowPath |
	
	((fromPoint dist: toPoint) < 0.0000000001) ifTrue: [ ^self ].
	
	canvas setPaint: lineColor.
	stroke := canvas setStrokePaint: lineColor.
	stroke width: self lineWidth.

	self showArrowHead ifTrue: [
		| lineLength arrowWidth arrowLength lineVector lineNormal |
		lineLength := fromPoint dist: toPoint.
		arrowLength := lineLength * 0.8.
		
		arrowLength > maxArrowLength ifTrue: [ arrowLength := maxArrowLength ].
		arrowLength < minArrowLength ifTrue: [ arrowLength := minArrowLength ].
		
		arrowWidth := arrowLength * 0.6667.
		
		lineVector := ((fromPoint - toPoint) normalized) * arrowLength.
		lineNormal := lineVector normal * arrowWidth.
	
		arrowPath := canvas createPath: [ :pathBuilder |
			pathBuilder absolute ;
				moveTo: (toPoint + lineVector + lineNormal);
				lineTo: toPoint;
				lineTo: (toPoint + lineVector - lineNormal)
		].
		canvas drawShape: arrowPath.
	].

	path := canvas createPath: [ :pathBuilder |
		pathBuilder absolute; 
			moveTo: fromPoint;
			lineTo: toPoint.
	].
	
	dashStyle ifNotNil: [
		stroke dashes: dashStyle offset: 0.
	].
	
	canvas drawShape: path.
	
	

	
	
	
]

{ #category : #accessing }
VMFigureRenderer >> showArrowHead [
	^ showArrowHead
]

{ #category : #accessing }
VMFigureRenderer >> showArrowHead: anObject [
	showArrowHead := anObject
]

{ #category : #accessing }
VMFigureRenderer >> showVertices [
	^ showVertices
]

{ #category : #accessing }
VMFigureRenderer >> showVertices: anObject [
	showVertices := anObject
]

{ #category : #accessing }
VMFigureRenderer >> verticeRenderer [
	^ verticeRenderer ifNil: [ 
			verticeRenderer := VMPointRendererOld new 
				textScale: self textScale;
				color: self color ;
				textColor: self textColor;
				yourself ]
]
