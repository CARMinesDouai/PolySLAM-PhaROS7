Class {
	#name : #VMKeyFrameRenderer,
	#superclass : #VMFigureRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #rendering }
VMKeyFrameRenderer >> renderOn: canvas [
	model ifNil: [ ^self. ].
	
	model location ifNotNil: [
		model location asRenderableElement renderOn: canvas.
	].
	
	model data do: [ :scanData |
		(scanData asRenderableElement)
			color: self color;
			lineWidth: self lineWidth;
			renderOn: canvas frame: model location frame.
		
		"Transcript
			show: 'KF frame: ', model location frame printString, ', data frame: ', scanData tf printString;
			cr.
		"
	].



]
