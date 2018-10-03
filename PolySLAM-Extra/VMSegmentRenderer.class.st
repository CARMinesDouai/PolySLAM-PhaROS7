Class {
	#name : #VMSegmentRenderer,
	#superclass : #VMFigureRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #accessing }
VMSegmentRenderer >> fromPoint [
	^ model pointA
]

{ #category : #accessing }
VMSegmentRenderer >> labelPosition [
	^ self fromPoint 
]

{ #category : #accessing }
VMSegmentRenderer >> points [ 
	^ { self fromPoint . self toPoint }
]

{ #category : #rendering }
VMSegmentRenderer >> renderOn: canvas [	
	
	self renderStyledLineFrom: self fromPoint to: self toPoint in: canvas.
	
	super renderOn: canvas	
	
]

{ #category : #accessing }
VMSegmentRenderer >> toPoint [
	^ model pointB
]
