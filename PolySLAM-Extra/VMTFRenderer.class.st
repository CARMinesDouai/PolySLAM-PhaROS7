Class {
	#name : #VMTFRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #accessing }
VMTFRenderer >> bounds [
	^ Rectangle center: model translate asPoint extent: 0.01@0.01
]

{ #category : #rendering }
VMTFRenderer >> renderOn: aCanvas [
	| tf centerPoint theta |
	tf := model asVMTFMatrix.
	centerPoint := tf translate asPoint.
	theta := tf angle. "[-pi, pi]"
	
	self renderFilledPoint: centerPoint radius: lineWidth on: aCanvas color: self color.
	self renderStyledLineSegFrom: centerPoint to: ((centerPoint+(0@(2*lineWidth))) rotateBy: theta negated about: centerPoint) on: aCanvas color: Color red.
]
