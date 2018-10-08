Class {
	#name : #VMGraphRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #rendering }
VMGraphRenderer >> renderOn: aCanvas [
	| sectorsCovered |
	
	model ifNil: [ ^self ].
	
	sectorsCovered := Set new.
	
	model do: [ :aNode |
		self renderPoint: aNode center radius: (lineWidth * 2) on: aCanvas color: color.
		sectorsCovered add: aNode sector.
		aNode neighbors do: [ :sector |
			sector ifNotNil: [
				| s |
				s := sector asPolygon.
				(sectorsCovered includes: s) ifFalse: [
					self renderStyledLineSegFrom: aNode center to: s centroid on: aCanvas color: color
				].
			].
		].
	].

]
