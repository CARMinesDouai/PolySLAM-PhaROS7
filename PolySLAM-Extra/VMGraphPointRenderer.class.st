Class {
	#name : #VMGraphPointRenderer,
	#superclass : #VMPointRendererOld,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #accessing }
VMGraphPointRenderer >> centerPoint [
	^ self model point
	
]

{ #category : #accessing }
VMGraphPointRenderer >> label [
	^ self model id asString
]
