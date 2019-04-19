Class {
	#name : #PSMapMergerTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
PSMapMergerTest >> testMerge [
	|l c merger i|
	l := FLMaterializer materializeFromFileNamed: '/home/mrsang/kf-test.fuel'.
	c := l collect:[:e| (VMVectorCollectionSimplifier compute: (e polygon) inlierThreshold: 0.01 ) result].
	merger := PSMapMerger new.
	i := 0.
	c do:[:chain|
		i % 3 = 0
			ifTrue:[
				merger consume: chain.
				merger chains asRenderableElement inspect.
				self halt.
			].
		i := i+1
	].
	
]
