Class {
	#name : #VMGraphRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMGraphRenderer >> renderOn: aCanvas [
	| sectorsCovered |
	
	model ifNil: [ ^self ].
	
	sectorsCovered := Set new.
	
	model do: [ :aNode |
		self renderPoint: aNode center radius: (lineWidth * 2) on: aCanvas color: color.
		sectorsCovered add: aNode sector.
		aNode neighbors do: [ :sector |
			sector ifNotNil: [
				(sectorsCovered includes: sector) ifFalse: [
					self renderStyledLineSegFrom: aNode center to: sector centroid on: aCanvas color: color
				].
			].
		].
	].
	
	
]
