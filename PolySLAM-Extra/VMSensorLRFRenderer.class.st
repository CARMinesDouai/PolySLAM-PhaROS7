Class {
	#name : #VMSensorLRFRenderer,
	#superclass : #VMSensorRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMSensorLRFRenderer >> initialize [
	super initialize.
	
	color := Color red.
	self showArrowHead: false.
]

{ #category : #'as yet unclassified' }
VMSensorLRFRenderer >> renderGlobalOn: canvas [
	| lineSegments intersectionPoints |
	
	lineSegments := model computeRays.
	intersectionPoints := model globalFrameData collection.
	
	intersectionPoints doWithIndex: [ :point :index |
		| lineSeg |
		lineSeg := lineSegments at: index.
		self renderStyledLineFrom: (lineSeg pointA) to: (point ifNil:[ lineSeg pointB] ifNotNil: [ point ]) in: canvas.
	].
	
	intersectionPoints do: [ :point |
		point ifNotNil: [ self renderPoint: point radius: (lineWidth * 2) in: canvas ].
	].
	
	super renderOn: canvas
]

{ #category : #'as yet unclassified' }
VMSensorLRFRenderer >> renderLocalOn: canvas [
	| intersectionPoints endPoints |
	
	endPoints := self model localEndPoints.
	intersectionPoints := model localFrameData collection.
	
	intersectionPoints doWithIndex: [ :point :index |
		| toPoint |
		toPoint := point
			ifNil:[ (endPoints at: index) rotateBy: ((Float halfPi negated) + rotationAngle) about: 0@0 ]
			ifNotNil: [ point rotateBy: rotationAngle about: 0@0 ].
		self renderStyledLineFrom: 0@0 to: toPoint in: canvas.
	].
	
	intersectionPoints do: [ :point |
		point ifNotNil: [ self renderPoint: (point rotateBy: rotationAngle about: 0@0) radius: (lineWidth * 2) in: canvas ].
	].
	
	"super renderOn: canvas"
]

{ #category : #'as yet unclassified' }
VMSensorLRFRenderer >> renderOn: canvas [
	
	useGlobalFrame
		ifTrue: [ self renderGlobalOn: canvas ]
		ifFalse: [self renderLocalOn:  canvas ].
]
