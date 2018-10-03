Class {
	#name : #VMPolygonCollectionRenderer,
	#superclass : #VMCollectionRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMPolygonCollectionRenderer >> renderOn: aCanvas viewer: aViewer [
	model do: [ :polygon |
		(polygon asRenderableElement)
			lineWidth: lineWidth;
			renderOn: aCanvas viewer: aViewer
	].
]

{ #category : #'as yet unclassified' }
VMPolygonCollectionRenderer >> sortPolygons [
	"note: sorting in place. the original collection is modified"
	model sort: [ :first :second | (second isCW not or: [first isCW])not ].
]
