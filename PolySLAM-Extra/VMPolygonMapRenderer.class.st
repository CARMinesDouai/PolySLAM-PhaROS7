Class {
	#name : #VMPolygonMapRenderer,
	#superclass : #VMFigureRenderer,
	#instVars : [
		'visGraphRenderer'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #initialization }
VMPolygonMapRenderer >> initialize [
	super initialize.
	color := Color blue
]

{ #category : #rendering }
VMPolygonMapRenderer >> renderOn: canvas [	

	| polygons |
	polygons := self model polygons collect: #asRenderableElement.
	
	polygons do: [ :p | 
		p showArrowHead: false;
			color: self color;
			lineWidth: lineWidth;
			renderOn: canvas 
	].
	
	self model visGraph ifNotNil: [
		self visGraphRenderer 
			model: self model visGraph;
			renderOn: canvas
	].
	

]

{ #category : #rendering }
VMPolygonMapRenderer >> visGraphRenderer [
	^ visGraphRenderer ifNil: [ 
			visGraphRenderer := VMVisGraphRenderer new
				dashStyle: self dashStyle;
				textScale: self textScale;
				textColor: self textColor;
				lineWidth: (0.2*self lineWidth) ;
				yourself.
				
			visGraphRenderer verticeRenderer 
				radius: 0.02;
				lineWidth: 0.02.
			
			visGraphRenderer
		]
]
