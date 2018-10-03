Class {
	#name : #VMKeyFrameCollectionRenderer,
	#superclass : #VMFigureRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMKeyFrameCollectionRenderer >> renderOn: canvas [
	| runningNumber |
	
	runningNumber := 0.
	
	model collection do: [ :keyframe |
		| hue sat value |
		
		hue := 17 * runningNumber.
		sat := 1.0.
		value := 1.0.
		(keyframe asRenderableElement)
			color: (Color h: hue s: sat v: value);
			lineWidth: self lineWidth;
			renderOn: canvas.
		
		runningNumber := runningNumber + 1.
	].
]
