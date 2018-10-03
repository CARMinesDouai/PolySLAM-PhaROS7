Class {
	#name : #VMMapRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #rendering }
VMMapRenderer >> renderOn: aCanvas viewer: aVMViewer [
	
	model polygons do: [ :aPolygon |
		(aPolygon asRenderableElement)
			autoColor;
			renderOn: aCanvas viewer: aVMViewer.
	].

]
