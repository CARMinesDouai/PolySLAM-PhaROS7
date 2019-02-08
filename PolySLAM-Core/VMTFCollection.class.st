Class {
	#name : #VMTFCollection,
	#superclass : #VMRenderCollection,
	#category : #'PolySLAM-Core-Collections'
}

{ #category : #accessing }
VMTFCollection >> bounds [
	| rect |
	self isEmpty ifTrue: [ ^ nil ].
	
	rect := VMRectangle origin: self first asPoint corner: self first asPoint.
	self allButFirstDo: [ :tfMatrix |
		rect encompass: tfMatrix asPoint. ]. 
	
	^ rect

]
