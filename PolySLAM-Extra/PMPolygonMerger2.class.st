Class {
	#name : #PMPolygonMerger2,
	#superclass : #Object,
	#category : #'PolySLAM-Extra-Experimental'
}

{ #category : #'as yet unclassified' }
PMPolygonMerger2 >> mergePolygon: polygonA with: polygonB [
	| newPolygon |
	newPolygon := polygonA copy.
	
	newPolygon doWithIndex: [ :vector |
		vector isSector ifTrue: [
			
		].
	].
]
