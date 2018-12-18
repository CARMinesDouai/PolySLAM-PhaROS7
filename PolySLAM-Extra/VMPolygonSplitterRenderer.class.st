Class {
	#name : #VMPolygonSplitterRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #rendering }
VMPolygonSplitterRenderer >> renderOn: aCanvas [
	model originalPolygon ifNil: [ ^ self ].
	
	model originalPolygon isCW
		ifTrue: [
			self renderFilledPolygonOn: aCanvas lineSegments: model originalPolygon color: Color veryLightGray. ]
		ifFalse: [
			self renderFilledPolygonOn: aCanvas lineSegments: model originalPolygon color: Color white. ].

	self model do: [ :lineSeg |
		self renderArrow: lineSeg on: aCanvas. ].
	
	model plane ifNotNil: [
		| bounds ls |
		bounds := model originalPolygon bounds.
		bounds := bounds expandBy: ((bounds width max: bounds height) * 0.15).
		ls := model originalPolygon fitIntoRectangle: bounds.
		self renderStyledLineSegFrom: ls pointA to: ls pointB on: aCanvas color: Color cyan. ].
]
