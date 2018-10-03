Class {
	#name : #VMSensorLRF,
	#superclass : #VMSensor,
	#instVars : [
		'angle',
		'rayCount',
		'maxRange',
		'rayEndPoints',
		'debugRenderList',
		'globalFrameData',
		'localFrameData'
	],
	#category : #'PolySLAM-Extra-Simulator'
}

{ #category : #'rendering support' }
VMSensorLRF class >> rendererClass [
	^ VMSensorLRFRenderer.
]

{ #category : #accessing }
VMSensorLRF >> angle [
	^angle.
]

{ #category : #accessing }
VMSensorLRF >> angle: radians [
	angle := radians.
]

{ #category : #computing }
VMSensorLRF >> compute [
	| rayCollection pointCollection |
	rayCollection := self computeRays.
	pointCollection := VMScan2DData new.
	
	rayCollection do: [ :ray |
		"the line below adds points where the beams intersect and nil values otherwise"
		pointCollection add: (self computeClosestIntersection: ray).
	].
	
	"debug messag"
	Transcript
		show: 'sensor frame ', tf frame printString; cr;
		show: 'sensor parent frame ', tf parent frame printString; cr;
		show: 'sensor ', tf printString; cr;
		show: 'sensor parent ', tf parent printString;
		cr.
	
	globalFrameData := pointCollection.
	self dataToLocalFrame.
]

{ #category : #computing }
VMSensorLRF >> computeClosestIntersection: ray [
	"returns the intersection point closest to the start point 'pointA' of 'ray' or nil if there are no intersections at all"
	| lineIntersection bestT bestPoint |
	
	bestPoint := nil.
	bestT := 2.0. "any value greater than 1.0 will do"
	
	lineIntersection := VMLineSegIntersection new.
	self map lineSegments do: [ :lineSeg |
		
		(lineIntersection computeIntersection: ray with: lineSeg) ifTrue: [
			
			(bestT > lineIntersection t) ifTrue: [ 
				bestT := lineIntersection t.
				bestPoint := lineIntersection intersectionPoint.
				debugRenderList addAll: {
					lineSeg asRenderableElement lineWidth: 0.05; color: Color green.
					(VMGraphVertex point: bestPoint) asRenderableElement lineWidth: 0.05; color: Color cyan.
				}.
			].
		
		].
	
	].

	^bestPoint.
]

{ #category : #computing }
VMSensorLRF >> computeRays [
	"returns an ordered collection of lineSegments, representing the beams of the laser range finder in the global frame."
	| rayCollection frame startPoint orientation |
	
	rayCollection := OrderedCollection new.
	frame := tf frame.
	startPoint := frame position.
	orientation := frame orientation - Float halfPi.
	
	rayEndPoints do: [ :point |
		| endPoint |
		
		endPoint := ( point rotateBy: orientation about: 0@0 ) + startPoint.
		
		rayCollection add: (VMLineSegment from: startPoint to: endPoint).
	].
	
	^rayCollection.
]

{ #category : #initialization }
VMSensorLRF >> data [
	^self localFrameData.
]

{ #category : #initialization }
VMSensorLRF >> dataToLocalFrame [
	| newData frame |
	
	newData := VMScan2DData new.
	frame := tf frame.
	
	globalFrameData collection do: [ :point |
		point ifNil: [
			newData add: nil.
		] ifNotNil: [
			| newPoint |
			newPoint := point + (frame position negated).
			newPoint := newPoint rotateBy: (frame orientation negated) about: 0@0.
			newData add: newPoint.
		].
	].
	
	localFrameData := newData.
	
	^newData.



]

{ #category : #accessing }
VMSensorLRF >> debugRenderList [
	^debugRenderList.
]

{ #category : #initialization }
VMSensorLRF >> globalFrameData [
	^globalFrameData.
]

{ #category : #initialization }
VMSensorLRF >> initEndPoints [
	"computes the end points of the laser beams from the local frame (i.e. with the sensor at 0@0 with orientation 0.0)"
	| currentAngle increment |
	
	rayEndPoints := OrderedCollection new.
	
	currentAngle := angle * -0.5.
	increment := (rayCount < 2)
		ifTrue: [ 0 ]
		ifFalse: [ angle / (rayCount - 1) ].
	
	1 to: rayCount do: [ :i |
		| vector endPoint |
		
		vector := (maxRange @ 0) rotateBy: (currentAngle) about: 0@0.
		endPoint := self centerPoint + vector.
		
		rayEndPoints add: endPoint.
		
		currentAngle := currentAngle + increment.
	].
]

{ #category : #initialization }
VMSensorLRF >> initialize [
	super initialize.
	
	angle := Float pi.
	rayCount := 30.
	maxRange := 4.0.
	globalFrameData := OrderedCollection new.
	localFrameData := OrderedCollection new.
	
	debugRenderList := OrderedCollection new.
	
	self initEndPoints.
]

{ #category : #initialization }
VMSensorLRF >> localEndPoints [
	^rayEndPoints.
]

{ #category : #initialization }
VMSensorLRF >> localFrameData [
	^localFrameData.
]

{ #category : #accessing }
VMSensorLRF >> maxRange [
	^maxRange.
]

{ #category : #accessing }
VMSensorLRF >> maxRange: aNumber [
	maxRange := aNumber.
]

{ #category : #accessing }
VMSensorLRF >> rayCount [
	^rayCount.
]

{ #category : #accessing }
VMSensorLRF >> rayCount: count [
	rayCount := count.
	
	self initEndPoints.
]

{ #category : #spinning }
VMSensorLRF >> spinOnce [
	self compute.
]
