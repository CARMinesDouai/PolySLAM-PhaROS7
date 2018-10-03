Class {
	#name : #VMMapMergeExamples,
	#superclass : #Object,
	#category : #'PolySLAM-PhaROS-Examples-Examples'
}

{ #category : #example }
VMMapMergeExamples class >> exampleMapMerge [
	| merger viewer |
	
	merger := VMMapMerger new.
	
	viewer := (VMMapViewer openOn: { merger asRenderableElement } extent: 600@600)
		zoomFactor: 30 at: 0@0;
		panTo: 300@300.
	
	merger mergeMap: VMExampleData localMap_2 withMap: VMExampleData localMap_1.

]
