Class {
	#name : #VMLocalMapRenderer,
	#superclass : #VMFigureRenderer,
	#instVars : [
		'showFrontiers',
		'colorObstacle',
		'colorFrontier'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #accessing }
VMLocalMapRenderer >> colorObstacle: colorA frontier: colorB [
	colorObstacle := colorA.
	colorFrontier := colorB.
	

]

{ #category : #initialization }
VMLocalMapRenderer >> initialize [
	super initialize.
	showFrontiers := true.
	showVertices := false.
	
	minArrowLength := 0.2.
	maxArrowLength := 0.2.	
		
	colorObstacle := Color red.
	colorFrontier := Color green.
]

{ #category : #rendering }
VMLocalMapRenderer >> lineColorByType: type [
	
	(type isObstacle) ifTrue: [
		^colorObstacle.
	].

	(type isFrontier) ifTrue: [
		^colorFrontier.
	].

	"unsupported type"
	^Color yellow.
]

{ #category : #accessing }
VMLocalMapRenderer >> points [
	^model lineSegments collect: [ :lineSeg | lineSeg pointA ].
]

{ #category : #rendering }
VMLocalMapRenderer >> renderBackgroundOn: canvas [
	| lines frame path point |
	
	model ifNil: [ ^self. ].
	
	lines := model lineSegments.
	
	frame := model tf asVMTransformationFrame.
	
	path := canvas createPath: [ :pathBuilder |
		pathBuilder absolute.
		
		point := (lines first pointA rotateBy: frame orientation about: (0@0)) + frame position.
		
		pathBuilder
			moveTo: point.
		
		lines do: [ :line |
			point := (line pointB rotateBy: frame orientation about: (0@0)) + frame position.
			pathBuilder
				lineTo: point.
		].
	].
	canvas setPaint: Color white.
	canvas drawShape: path.

]

{ #category : #rendering }
VMLocalMapRenderer >> renderOn: canvas [
	| frame |
	
	model ifNil: [ ^self. ].
	
	self renderBackgroundOn: canvas.
	
	frame := model tf asVMTransformationFrame.
	
	model lineSegments do: [ :line |
		|from to |
		
		from := (line pointA rotateBy: frame orientation about: (0@0)) + frame position.
		to  := (line pointB rotateBy: frame orientation about: (0@0)) + frame position.
		
		self setLineStyleByType: (line type).
		( showFrontiers or: [line isObstacle] ) ifTrue: [
			self renderStyledLineFrom: from to: to in: canvas color: (self lineColorByType: line type).
		].
	].
	
	self renderLabel: canvas.
	
	"super renderOn: canvas."
]

{ #category : #rendering }
VMLocalMapRenderer >> setLineStyleByType: type [

	(type isObstacle) ifTrue: [
		^self beSolid.
	].

	(type isFrontier) ifTrue: [
		^self beDotted.
	].

	"unsupported type"
	^self beDashed.
]

{ #category : #'as yet unclassified' }
VMLocalMapRenderer >> showFrontiers [
	^showFrontiers.
]

{ #category : #'as yet unclassified' }
VMLocalMapRenderer >> showFrontiers: aBoolean [
	showFrontiers := aBoolean
]
