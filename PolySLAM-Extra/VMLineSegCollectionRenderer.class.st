Class {
	#name : #VMLineSegCollectionRenderer,
	#superclass : #VMCollectionRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMLineSegCollectionRenderer >> renderOn: aCanvas [
	| collection |
	collection := self model.
	
	"Transcript show: self class printString, ' collection size=', collection size printString; cr."
	collection do: [ :lineSeg |
		"Transcript show: '    lineSeg=', lineSeg printString; cr."
		"self renderArrow: lineSeg on: aCanvas."
		self renderArrow: lineSeg on: aCanvas color: color.
	].

]

{ #category : #'as yet unclassified' }
VMLineSegCollectionRenderer >> renderOn: aCanvas viewer: viewer [
	^self renderOn: aCanvas

]
