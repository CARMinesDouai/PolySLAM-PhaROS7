Class {
	#name : #VMICPTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #'test data' }
VMICPTest class >> dataSet [
	"this data set contains two 'normal' scans that should not pose any problems. the two scans are already very close and need only little correction"
	| dataA dataB tfMat |
	
	dataA := {
		(0.054007272784261845@ -1.4509952496429497). (-0.06717201912785864@ -1.4984952184929674).
		(-0.1896852637989709@ -1.4879581649688658). (-0.290195527318446@ -1.369593573263386).
		(-0.387638963422404@ -1.2952374431110323). (-0.5099095493668713@ -1.3038375096094124).
		(-0.637833620540655@ -1.3044049495873586). (-0.7936703574785196@ -1.3337133738775806).
		(-0.900245509260601@ -1.2642238816982223). (-0.936288146592482@ -1.109805616561033).
		(-0.9535177575328116@ -0.9584925070492718). (-1.0653483921287028@ -0.9083131637209646).
		(-1.3000995935409845@ -0.9360261998868233). (-1.372399268828085@ -0.8263923081201431).
		(-1.3906734761596153@ -0.6890074620104863). (-1.3941069280381857@ -0.5535935993090357).
		(-1.4347663861774733@ -0.4375447601048754). (-1.4657838796671734@ -0.31855551809354893).
		(-1.4869509637189016@ -0.19742550872526465). (-1.4981253905924494@ -0.07496875390601708).
		(-1.4992320655337632@0.04799180841942059). (-1.4902635514292013@0.17062985460236438).
		(-1.522284496235875@0.3022480976282373). (-1.540493175860961@0.4396416439849741).
		(-1.5442297590685925@0.581252484903899). (-1.5818214568712976@0.7485592017880521).
		(-1.603507384925732@0.9266434408598816). (-1.6044130684286049@1.1118285415726243).
		(-1.6624577590378777@1.3665058358509705). (-1.6511945401051693@1.6011110488429212).
		(-1.4499713439754456@1.6572227073178907). (-1.2498969751154816@1.6900182104335943).
		(-1.1599479524968608@1.8717170586117822). (-1.207661468834062@2.3610713196965394).
		(-1.7522541920876542@4.253187657076895). (0.08641121805761964@4.499170268104309).
		(0.45989312970529667@4.528708680104062). } asOrderedCollection.
	dataB := {
		(-1.0330121286784824@ -1.2244549571148589). (-1.0578969203396578@ -1.0634162430280383).
		(-0.49242693624572137@ -1.2591345092799469). (-0.6149910941852046@ -1.2576907227426324).
		(-0.7425318035172747@ -1.2477782338081487). (-0.900245509260601@ -1.2642238816982223).
		(-0.31092377926976356@ -1.4674216856393418). (-0.4449820053487951@ -1.4868406151688771).
		(-0.06502251451576715@ -1.4505433715011926). (-0.18361533535740385@ -1.4403435036898622).
		(0.054007272784261845@ -1.4509952496429497). (-1.4784866209171168@ -0.7325143764931074).
		(-1.5335176208420043@ -0.6089529592399393). (-1.5323305004375418@ -0.46729780379200697).
		(-1.5165977208289687@ -0.3295987760541253). (-1.5384985971278236@ -0.2042695930277405).
		(-1.4981253905924494@ -0.07496875390601708). (-1.5512054438056002@0.049655524444627175).
		(-1.5419260212120804@0.17654502289524635). (-1.5713271668620308@0.31198547190749754).
		(-1.5866502747631621@0.4528144273253479). (-1.592896393899845@0.5995707450342036).
		(-1.5818214568712976@0.7485592017880521). (-1.603507384925732@0.9266434408598816).
		(-1.0653483921287028@ -0.9083131637209646). (-1.136166935678763@ -0.8180004243705074).
		(-1.4135198461712488@ -0.8511531263409714). (-1.6438658487998001@1.1391685876768691).
		(-1.6624577590378777@1.3665058358509705). (-1.6511945401051693@1.6011110488429212).
		(-1.5145023120542804@1.730977396381085). (-1.279628111535926@1.7302184533078475).
		(-1.133609443130447@1.8292166712681905). (-1.1612129508019826@2.2702608843235956).
		(-1.7911085241730758@4.347497470342512). (-1.3834079580904781@4.3366907223702205).
		(0.08641121805761964@4.499170268104309). (0.45989312970529667@4.528708680104062). } asOrderedCollection.
	
	tfMat := VMTFMatrix identity.
	
	^{ dataA. dataB. tfMat. }.

]

{ #category : #'test data' }
VMICPTest class >> dataSet2 [
	"a data set with zero translation an rotation of +0.788"
	| dataA dataB tfMat |
	
	dataA := { (0.1301828200722565@ -3.4975780810952646). (-0.14553937477702705@ -3.246739640068096). (-0.38569336972457424@ -3.025514935436694). (-0.6015338716272359@ -2.838971821150247). (-0.6313468916095663@ -2.1095509243568733). (-0.765592766263688@ -1.9576188894278461). (-0.9005226736283352@ -1.8416185583017115). (-1.0227710792248963@ -1.7187028013886347). (-1.1601101923461352@ -1.6291544867245134). (-1.6443076954620037@ -1.9490387894150376). (-1.7984247645774185@ -1.8078076131476652). (-1.9404559999487088@ -1.6544275482060427). (-2.1116474047401006@ -1.5203122172943284). (-2.271911898209789@ -1.3680352067007613). (-2.4211338483139695@ -1.1995477850208338). (-2.602332932337947@ -1.0333747187102). (-2.775794701791352@ -0.8465032625495656). (-2.5915058992515627@ -0.5632061559893946). (-2.478251606198169@ -0.32904251454210776). (-3.495625911382382@ -0.1749270924473732). (-3.798054566018867@0.12157924799586552). (-4.174724962070336@0.4779910993594234). (-4.611972745683688@0.9157026772216312). (-5.28883424921054@1.509381424417826). (-1.5442297590685925@0.581252484903899). (-1.4480445565187536@0.6852524807225484). (-1.3437599683610886@0.7765392117789073). (-1.275639898668645@0.8839948240372505). (-1.1989472314250864@0.9855097849631533). (-1.1141973592361838@1.080401890349658). (-1.0219598210035838@1.1680334431232364). (-0.9228544744905934@1.247815538816812). (-0.8175473307334823@1.319212023145089). (-0.7295149596803043@1.4262580143868235). (-0.6285259602053542@1.525599920473234). (-0.53184620532916@1.6672251239340694). (-0.4051924041098791@1.7558539562422772). (-0.27415269266369335@1.8801170977110035). (-0.12864787979736647@2.045959364949275). (0.042283889369528545@2.2015939845257084). (0.2426764713427334@2.389709633042609).  } asOrderedCollection.
	dataB := { (-1.712567643659306@ -4.379031407273898). (-2.0654915177563082@ -4.224044127382755). (-2.429081313159129@ -4.081919153298007). (-2.610247932778804@ -3.665597595130155). (-0.5250488101955515@ -4.118668200633821). (-0.8710011469943643@ -4.110737282037676). (-1.305127634244662@ -4.360888196036552). (-0.18593214894591273@ -4.147834764788534). (0.15443401969714546@ -4.149126912202154). (-3.031974425122487@ -3.5938746618939237). (-3.034048367534139@ -3.049877785004414). (-3.007326318351881@ -2.564038302160894). (-3.0043499970591285@ -2.163026836442584). (-2.9983754312723456@ -1.8054763286020603). (-3.003567971705561@ -1.4881140545484215). (-2.4647810487715125@ -0.9787534835783752). (-2.439102856501705@ -0.7438260921782882). (-2.442973132778622@ -0.5309258634892482). (-2.4306691753591645@ -0.3227248982628993). (-2.9984641310675264@0.09598361683884118). (-2.9805271028584026@0.34125970920472876). (-2.4968756509874157@ -0.12494792317669513). (-2.942560237569346@0.5842424567556133). (-2.9328989927440268@0.8370206080862491). (-2.9499467882328507@1.1103683832830846). (-2.9376684199038388@1.3901813747492398). (-2.8139303461169702@1.626129148377222). (-2.8598599553709216@2.350745633977831). (-2.344152700388515@1.6244544060272152). (-0.9755783869319646@1.5742143472066397). (-0.7969108485895958@1.558022175516193). (-0.6483340510724319@1.573679433118451). (-0.5014549935960652@1.5719551168521229). (-0.36022099410878267@1.5609756037181621). (-0.22393946263897477@1.5357588082355145). (-0.09739585826610381@1.5489409436103783). (0.02980226898342793@1.5517138346884194). (0.15680011803660376@1.5440588469950578). (-2.837182966302447@2.7511264630553147). (-2.832777802807615@3.2376803301006207). (-2.795916068978589@3.7804308398947484).  } asOrderedCollection.
	tfMat := VMTFMatrix angle: 0.7884168869682977 translation: 0.0 @ 0.0.
	
	^{ dataA. dataB. tfMat. }.

]

{ #category : #'test data' }
VMICPTest class >> dataSet3 [
	"a data set with decent overlap and only little initial misalignment"
	| dataA dataB tfMat |
	
	dataA := { (0.055792637173824225@ -1.4989620347551134). (-0.06717201912785864@ -1.4984952184929674). (-0.1896852637989709@ -1.4879581649688658). (-0.31092377926976356@ -1.4674216856393418). (-0.43007281444793344@ -1.4370237904338374). (-0.5652711575838458@ -1.4453970106527199). (-0.7037255234890698@ -1.4391575270240693). (-0.8437861403605396@ -1.4179298111456238). (-1.1891129471547885@ -1.6698833488926261). (-1.3876667296604832@ -1.6448358724788865). (-1.6221086111874754@ -1.6305715726429921). (-1.8658816124996993@ -1.590845626745575). (-2.1116474047401006@ -1.5203122172943284). (-2.1845306713555663@ -1.3154184679815013). (-2.6003443478190746@ -1.288337406413938). (-2.650661972509937@ -1.0525659634862465). (-2.678230587531284@ -0.8167502188624342). (-3.031241063151714@ -0.6587728114174591). (-3.023466959561767@ -0.4014318677413715). (-2.996250781184899@ -0.14993750781203416). (-2.9984641310675264@0.09598361683884118). (-2.9805271028584026@0.34125970920472876). (-2.942560237569346@0.5842424567556133). (-2.9328989927440268@0.8370206080862491). (-2.9031519470489537@1.09275467161933). (-2.849086418319046@1.3482620594491088). (-2.8572215822110776@1.6511465198907178). (-2.590732577708485@1.7953296941787458). (-2.2804717958549325@1.8745005703680597). (-2.2269588971331453@2.159411510222061). (-2.207222500002586@2.522711405508433). (-2.647260386876367@3.579429625523484). (-2.582227458283202@4.166737975165739). (-2.2550300126946734@4.408757607517821). (-2.4005882431600862@5.826867090195346). (-2.2495574924836816@7.051885924205704). (-0.6207394125469521@4.256980923343546). (-0.26670901909210126@4.241623073675327). (0.08068887517291505@4.20122521479429). (0.4245322783439491@4.18049953290801).  } asOrderedCollection.
	
	dataB := { (-2.6003443478190746@ -1.288337406413938). (-2.602332932337947@ -1.0333747187102). (-1.694045601770572@ -1.7028838771688986). (-1.9800260830849175@ -1.6881648942871068). (-2.069446918557747@ -1.4899293443891384). (-2.3558664102854143@ -1.4185885439016188). (-1.219275812155788@ -1.7122413655474635). (-1.4199080570224831@ -1.6830523193301616). (-0.4449820053487951@ -1.4868406151688771). (-0.583482212918377@ -1.4919626359959133). (-0.7248109324325626@ -1.4822783518038167). (-0.8703781884203867@ -1.4626160839817282). (-0.06717201912785864@ -1.4984952184929674). (-0.1896852637989709@ -1.4879581649688658). (-0.31092377926976356@ -1.4674216856393418). (0.055792637173824225@ -1.4989620347551134). (-3.014922432820931@ -0.9194273892337115). (-2.9804272219899195@ -0.6477295534568829). (-2.973901927437803@ -0.3948510174505293). (-2.996250781184899@ -0.14993750781203416). (-2.9984641310675264@0.09598361683884118). (-2.9805271028584026@0.34125970920472876). (-2.942560237569346@0.5842424567556133). (-2.9328989927440268@0.8370206080862491). (-2.9499467882328507@1.1103683832830846). (-2.9376684199038388@1.3901813747492398). (-2.902244467748949@1.6771645862647533). (-2.426345992828505@1.681412835411059). (-2.356178515365022@1.9367299253464032). (-2.333209676235565@2.26243952553891). (-2.832777802807615@3.2376803301006207). (-2.795916068978589@3.7804308398947484). (-2.661242986382444@4.294239137196514). (-2.1867233685298513@4.275212849616434). (-0.6132362862214193@4.205525086985139). (-0.2636967760529434@4.193717683666759). (0.08068887517291505@4.20122521479429). (0.4245322783439491@4.18049953290801). (-2.629143137780215@6.381630697640158).  } asOrderedCollection.
	
	"tfMat := VMTFMatrix angle: 0.06529386330590414 translation: 0.40000842091479294 @ -0.24820459256221827."
	tfMat := VMTFMatrix angle: 0.06529386330590414 translation: ((0.40000842091479294 @ -0.24820459256221827) rotateBy: Float halfPi negated about: (0@0) ).
	
	
	^{ dataA. dataB. tfMat. }.

]

{ #category : #'test data' }
VMICPTest class >> dataSet4 [
	"a data set with decent overlap and only little initial misalignment"
	| dataA dataB tfMat |
	
	dataA := { (0.03354997248719297@ -0.9013758368994083). (-0.03815370686462371@ -0.8511452841040056). (-0.10141838771118313@ -0.7955616322033536). (-0.15546188963488178@ -0.7337108428196709). (-0.20070064674236895@ -0.6706111022024575). (-0.23747216156228576@ -0.6072157544752406). (-0.28641013814910954@ -0.5857245365915688). (-0.3334233718273162@ -0.5602971132526949). (-0.3491931678961867@ -0.4903755005040785). (-0.38818558143848086@ -0.46012602008935394). (-0.42456929736298266@ -0.42678438553525266). (-0.45809980861534216@ -0.3905746604000147). (-0.488551782341868@ -0.3517401824793181). (-0.5157205741788434@ -0.31054192851955437). (-0.5842262283866425@ -0.2894541657415188). (-0.6059718113872647@ -0.24062868449966088). (-0.669557646882821@ -0.20418755471560854). (-0.6840324771780143@ -0.14865924177698953). (-0.7434754818594508@ -0.09871275436263233). (-0.800997708836763@ -0.0400832937550838). (-0.8515638132231774@0.027259347182230897). (-0.9438335825718276@0.10806557458149744). (-1.0318577899743173@0.20487435483563507). (-1.1558506850092853@0.32986844948185945). (-1.310255553149109@0.49318392658512644). (-1.491431659335795@0.7057843902573063). (-1.4286107911055388@0.8255732599453589). (-1.3561893252598352@0.9398140848334171). (-1.2375731087261526@1.0172594558704715). (-1.1500928927167309@1.1152086522810258). (-1.0548837843091117@1.2056633865228252). (-0.9525856109110379@1.288015781691065). (-0.843885840099896@1.3617124104886809). (-0.7513730858130476@1.4689923369152675). (-0.571387236550322@1.3869090186120308). (-0.3956935767648951@1.2404154922069477). (-0.3040067316074121@1.3173776630630183). (-0.20951037355141197@1.4368052767770405). (-0.09739585826610381@1.5489409436103783). (0.03168411328779387@1.64969576497158). (0.2426764713427334@2.389709633042609).  } asOrderedCollection.
	
	dataB := { (-0.619891442095037@ -4.862647283118254). (-0.21504002390131816@ -4.797182692802154). (0.17861082913913598@ -4.798677127262704). (-0.9016789598823144@ -4.255522888354092). (-0.8601456288958669@ -2.874047580867675). (-0.8930701536054059@ -2.283578266830199). (-0.9233651999837856@ -1.8883327851464378). (-0.947086019362254@ -1.591518794085876). (-0.9570909086855617@ -1.3440524515477237). (-0.9672398208600022@ -1.1464934055382572). (-0.9873704589836807@ -0.9925218268261691). (-0.9907740046796937@ -0.844731242260497). (-0.9754804690613378@ -0.7023117929238212). (-0.985180498846628@ -0.5932279365406771). (-0.987449852273129@ -0.4892308138760026). (-1.0242038897987205@ -0.4067067642923716). (-1.006249492172468@ -0.30686472508688595). (-1.0280030942732443@ -0.22341360335627566). (-1.0428482758881896@ -0.13846109011931895). (-0.9987502603949663@ -0.04997916927067805). (-1.0514614219610126@0.03365825497148698). (-1.0451715040690133@0.11966840469445822). (-1.0318577899743173@0.20487435483563507). (-1.011609750939907@0.28870350154319147). (-1.0313582996930843@0.3882062050691495). (-0.9960955688412401@0.47137842306881916). (-0.9956984301644665@0.5753995448104017). (-1.027416155499875@0.7119803672980431). (-1.044443722220823@0.8585111013338811). (-1.0424062922750894@1.0107883664869222). (-1.0219598210035838@1.1680334431232364). (-1.0405897747155533@1.4070085005988537). (-1.0535403746565493@1.7000154937436713). (-0.8652174927544184@1.691566933417581). (0.1365939172586909@1.3450821914544575). (-0.7054727747274642@1.7123703349796542). (-0.5476496354303694@1.716765527616682). (-0.4051924041098791@1.7558539562422772). (-0.2525090590323491@1.7316868005232926). (-0.10982136080262994@1.746550677395723). (0.03360436257796319@1.749677326485009).  } asOrderedCollection.
	
	tfMat := VMTFMatrix angle: 0.7122488050952137 translation: -0.3681551937787422 @ -0.19361982924701215.

	
	^{ dataA. dataB. tfMat. }.

]

{ #category : #'as yet unclassified' }
VMICPTest >> matrix: matrixA isSimilarTo: matrixB [
	"returns true if the values of each cell are the same (+/- epsilon) between the two provided matrices"
	| error epsilon returnValue |
	
	returnValue := true.
	epsilon := 0.0001.
	
	1 to: 2 do: [ :r |
		1 to: 2 do: [ :c |
			error := (matrixA at: r at: c) - (matrixB at: r at: c).
			(error abs > epsilon) ifTrue: [
				returnValue := false.
			].
		].
	].
	
	^returnValue.

]

{ #category : #tests }
VMICPTest >> testAlignmentStep [
	"in this test the icp algorithm should result in a (near) perfect alignment after only one iteration step.
	additionally the translation component is expected to be 0@0 (or very close to this)."
	| data data2 icp epsilon translate error |
	
	data := {  -3 @ -3.  -2 @ -2.  -1 @ -1.  0@0. 1@1.  2@2.  3@3.  }.
	data2 := data collect: [ :p |  p rotateBy: 0.3 about: 0@0  ].
	epsilon := 0.000001.
	
	icp := VMICP_old new.
	icp setupInputA: data2 nnCollection: (icp createNNCollection: data).

	icp iterateOnce.
	
	"
	(VMMapViewer
		openOn: { icp asRenderableElement showMatches: false. }
		extent: 800@800)
			zoomFactor: 50 at: 0@0;
			panTo: 300@350.
	"
	
	icp outputA doWithIndex: [ :p :index |
		self assert: (( p dist: (data at: index)) < epsilon).
	].
	
	translate := Point x: (icp stepVecT at: 1) y: (icp stepVecT at: 2).
	self assert: ((translate dist: (0@0)) < epsilon).
	
	error := icp computeError.
	self assert: (error >= 0.0).
	self assert: (error < epsilon).
	
]

{ #category : #tests }
VMICPTest >> testAlignmentStep2 [
	"in this test we expect a (near) perfect match after 5 iterations."
	| data data2 icp epsilon error |
	
	data := {
		1@ -2.  2@ -1.  3@0.  4@1.  4@2.  4@3.  3@3.  2@3.  1@3.
		1@4.  1@5.  1@6.  1@7.  1@8.  2@9.  3@10.
		4@10. 5@10.  7@10.
	}.
	
	data2 := data collect: [ :p |
		(p rotateBy: 0.3 about: 3.5@3.5) + (0.1@0.133)
	].
	
	epsilon := 0.000001.
	
	icp := VMICP_old new.
	icp setupInputA: data2 nnCollection: (icp createNNCollection: data).
	
	icp iterateOnce.
	icp iterateOnce.
	icp iterateOnce.
	icp iterateOnce.
	icp iterateOnce.
	
	icp outputA doWithIndex: [ :p :index |
	"	self assert: (( p dist: (data at: index)) < epsilon)."
	].
	
	error := icp computeError.
	self assert: (error >= 0.0).
	self assert: (error < epsilon).
	"
	(VMMapViewer
		openOn: { icp asRenderableElement showMatches: false }
		extent: 800@800)
			zoomFactor: 50 at: 0@0;
			panTo: 300@350.
	"

]

{ #category : #tests }
VMICPTest >> testAlignmentStep3 [
	"in this test we expect a (near) perfect match after 5 iterations."
	| data data2 icp epsilon error |
	
	data := {
		1@ -2.  2@ -1.  3@0.  4@1.  4@2.  4@3.  3@3.  2@3.  1@3.
		1@4.  1@5.  1@6.  1@7.  1@8.  2@9.  3@10.
		4@10. 5@10.  7@10.
	}.
	
	data2 := data collect: [ :p |
		(p rotateBy: -0.2 about: 3.5@3.5) + (0.1@0.133)
	].
	
	epsilon := 0.000001.
	
	icp := VMICP_old new.
	icp setupInputA: data2 nnCollection: (icp createNNCollection: data).
	
	icp iterateOnce.
	icp iterateOnce.
	icp iterateOnce.
	icp iterateOnce.
	icp iterateOnce.
	
	icp outputA doWithIndex: [ :p :index |
		self assert: (( p dist: (data at: index)) < epsilon).
	].
	
	error := icp computeError.
	self assert: (error >= 0.0).
	self assert: (error < epsilon).
	"
	(VMMapViewer
		openOn: { icp asRenderableElement }
		extent: 800@800)
			zoomFactor: 50 at: 0@0;
			panTo: 300@350.
	"

]

{ #category : #tests }
VMICPTest >> testCenterOfMass [
	| icp points expectedResult centerOfMass epsilon error |
	
	icp := VMICP_old new.
	points := { -2@1. -1@1. 0@1. 1@1. 2@1.}.
	expectedResult := 0@1.
	epsilon := 0.000001.
	
	centerOfMass := icp computeCentroid: points.
	
	"Transcript
		show: 'center of mass=', centerOfMass printString, ', expected result=', expectedResult printString;
		cr.
	"
	error := expectedResult dist: centerOfMass.
	self assert: (error < epsilon).

]

{ #category : #tests }
VMICPTest >> testCenterOfMass2 [
	| icp points  expectedResult centerOfMass epsilon error |
	
	icp := VMICP_old new.
	points := { -2@ -1.  -1@0. 0@1. 1@2. 2@3.}.
	expectedResult := 0@1.
	epsilon := 0.000001.
	
	centerOfMass := icp computeCentroid: points.
	
	"Transcript
		show: 'center of mass=', centerOfMass printString, ', expected result=', expectedResult printString;
		cr.
	"
	error := expectedResult dist: centerOfMass.
	self assert: (error < epsilon).

]

{ #category : #tests }
VMICPTest >> testCenterOfMass3 [
	"same as test 2, but using a quad-tree as source collection"
	| icp points quadtree expectedResult centerOfMass epsilon error |
	
	icp := VMICP_old new.
	points := { -2@ -1.  -1@0. 0@1. 1@2. 2@3.}.
	quadtree := (VMQuadTreeNode size: 1@1 center: 0@0)
		addAll: points;
		root.
	expectedResult := 0@1.
	epsilon := 0.000001.
	
	centerOfMass := icp computeCentroid: quadtree.
	
	"Transcript
		show: 'center of mass=', centerOfMass printString, ', expected result=', expectedResult printString;
		cr.
	"
	error := expectedResult dist: centerOfMass.
	self assert: (error < epsilon).

]

{ #category : #tests }
VMICPTest >> testFullICP [
	| data colA colB initialGuess icp error |
	
	icp := VMICP new.
	data := self class dataSet.
	
	colA := data first.
	colB := data second.
	initialGuess := data third inverse.
	
	icp compute: colA with: colB asVMQuadTree2 initialGuess: initialGuess.
	
	"icp inspect."
	
	error := icp finalError.
	self assert: (error >= 0.0).
	self assert: (error < 0.2).

]

{ #category : #tests }
VMICPTest >> testFullICP2 [
	"this test uses a data set with a good initial guess. the required transformation is mostly rotation."
	| data icp epsilon error |
	
	icp := VMICP new.
	epsilon := 0.000001.
	data := self class dataSet2.
	
	icp maxIterations: 20.
	icp compute: data first with: data second asVMQuadTree2 initialGuess: data third inverse.
	
	"
	Transcript show: 'testFullICP2'; cr.
	icp matchHistory do: [ :m |
		Transcript
			show: '    square error=';
			show: m squaredError printString;
			cr.
	].
	icp inspect."
	
	error := icp finalError.
	self assert: (error >= 0.0).
	self assert: (error < 0.7).

]

{ #category : #tests }
VMICPTest >> testFullICP_old [
	| data colA colB initialGuess icp |
	
	icp := VMICP_old new.
	data := self class dataSet.
	
	colA := data first.
	colB := data second.
	initialGuess := data third.
	
	"icp alignPointCollection: colA with: colB initialGuess: initialGuess."
	
	icp setupInputA: colA nnCollection: colB asVMQuadTree.
	icp tfMatrix: initialGuess.
	icp tfMatrix: VMTFMatrix identity.
	
	Transcript show: 'error=', icp computeError printString, '(initial)'; cr.
	icp iterateOnce.
	Transcript show: 'error=', icp computeError printString; cr.
	icp iterateOnce.
	Transcript show: 'error=', icp computeError printString; cr.
	icp iterateOnce.
	Transcript show: 'error=', icp computeError printString; cr.
	icp iterateOnce.
	Transcript show: 'error=', icp computeError printString; cr.
	icp iterateOnce.
	Transcript show: 'error=', icp computeError printString; cr.
	icp iterateOnce.
	Transcript show: 'error=', icp computeError printString; cr.
	icp iterateOnce.
	Transcript show: 'error=', icp computeError printString; cr.
	
	
	"
	(VMMapViewer
		openOn: { icp asRenderableElement }
		extent: 800@800)
			zoomFactor: 50 at: 0@0;
			panTo: 300@350.
	"


]

{ #category : #tests }
VMICPTest >> testFullICP_old2 [
	"this test uses a data set with a good initial guess. the required transformation is mostly rotation."
	| data icp epsilon viewer error |
	
	icp := VMICP_old new.
	epsilon := 0.000001.
	data := self class dataSet2.
	
	icp setupInputA: data first nnCollection: data second asVMQuadTree2.
	Transcript show: 'error=', icp computeError printString, ' (before initial guess)'; cr.
	icp applyTransform: data third inverse to: data first.
	
	
	
	1 to: 5 do: [ :i |
		icp iterateOnce.
		icp iterationHistory removeLast.
		Transcript show: 'error=', icp computeError printString; cr.
		icp iterateOnce.
		Transcript show: 'error=', icp computeError printString; cr.
	].
	
	
	"viewer := (VMMapViewer
		openOn: { icp asRenderableElement }
		extent: 800@800)
			zoomFactor: 50 at: 0@0;
			panTo: 300@350.
	"
	
	error := icp computeError.
	self assert: (error >= 0.0).
	self assert: (error < 6.0).


]

{ #category : #tests }
VMICPTest >> testFullICP_old3 [
	| data icp |
	
	icp := VMICP_old new.
	data := self class dataSet3.
	
	icp setupInputA: data first nnCollection: data second asVMQuadTree2.
	"icp applyTransform: data third to: data first."
	"icp tfMatrix: data third."
	Transcript show: 'error=', icp computeError printString, '(initial)'; cr.
	
	1 to: 1 do: [ :i |
		icp iterateOnce.
		"icp iterationHistory removeLast.
		Transcript show: 'error=', icp computeError printString; cr.
		icp iterateOnce."
		Transcript show: 'error=', icp computeError printString; cr.
	].
	
	
	"(VMMapViewer
		openOn: { icp asRenderableElement showMatches: false. }
		extent: 800@800)
			zoomFactor: 50 at: 0@0;
			panTo: 300@350.
	
	(VMMapViewer
		openOn: {
				data first asRenderableElement
					color: Color orange;
					label: 'InputA'.
				data second asRenderableElement
					color: Color blue;
					label: 'Target'.
				icp outputA asRenderableElement
					color: Color purple;
					label: 'OutputA'.
			}
		extent: 800@800)
			zoomFactor: 50 at: 0@0;
			panTo: 300@350.
	"


]

{ #category : #tests }
VMICPTest >> testFullICP_old4 [
	| data icp viewer |
	
	icp := VMICP_old new.
	data := self class dataSet4.
	
	icp setupInputA: data first nnCollection: data second asVMQuadTree2.
	icp applyTransform: data third inverse to: data first.
	"icp tfMatrix: data third."
	Transcript show: 'error=', icp computeError printString, '(initial)'; cr.
	
	1 to: 10 do: [ :i |
		icp iterateOnce.
		"icp iterationHistory removeLast.
		Transcript show: 'error=', icp computeError printString; cr.
		icp iterateOnce."
		Transcript show: 'error=', icp computeError printString; cr.
	].
	
	"
	viewer := (VMMapViewer
		openOn: { icp asRenderableElement showMatches: false. }
		extent: 800@800)
			zoomFactor: 50 at: 0@0;
			panTo: 300@350.
	
	viewer := (VMMapViewer
		openOn: {
				data first asRenderableElement
					color: Color orange;
					label: 'InputA'.
				data second asRenderableElement
					color: Color blue;
					label: 'Target'.
				icp outputA asRenderableElement
					color: Color purple;
					label: 'OutputA'.
			}
		extent: 800@800)
			zoomFactor: 50 at: 0@0;
			panTo: 300@350.
	"


]

{ #category : #tests }
VMICPTest >> testPointMatching [
	"tests if the icp point matching finds the correct nearest point in the provided quad-tree.
	note, that some ICP implementations in the literature are not as strict and only look for
	a good match, not necessarly the best/closest match."
	| icp quadtree sourceCollection shiftedPoints epsilon |
	
	icp := VMICP_old new.
	epsilon := 0.000001.
	
	sourceCollection := {
		0@1.  2@1.  4@1.  6@1.  3@ -3
	}.
	
	shiftedPoints := sourceCollection collect: [ :p | p + (0.1@0.3) ].
	
	"quadtree := (VMQuadTreeNode size: 1@1 center: 0@0)
		addAll: shiftedPoints;
		root.
	"
	quadtree := (VMQuadTreeNode2 rectangle: ((-0.5 @ -0.5) extent: 1@1))
		addAll: shiftedPoints;
		root.
	
	sourceCollection doWithIndex: [ :p :index |
		| matchingPoint error |
		
		matchingPoint := icp findCorrespondingPoint: p inNNCollection: quadtree.
		error := matchingPoint dist: (shiftedPoints at: index).
		
		self assert: error < epsilon.
	].
	
	
]

{ #category : #tests }
VMICPTest >> testTFMatrix [
	"in this test we check if the matrix returned via tfMatrix gives us a (near) identical resulting collection as the one returned via outputA."
	| data data2 data2Copy icp epsilon  |
	
	data := {
		1@ -2.  2@ -1.  3@0.  4@1.  4@2.  4@3.  3@3.  2@3.  1@3.
		1@4.  1@5.  1@6.  1@7.  1@8.  2@9.  3@10.
		4@10. 5@10.  7@10.
	}.
	
	data2 := data collect: [ :p |
		(p rotateBy: 0.3 about: 3.5@3.5) + (0.1@0.133)
	].
	
	data2Copy := data2 collect: [ :point |
		point copy
	].
	
	epsilon := 0.000001.
	
	icp := VMICP_old new.
	icp alignPointCollection: data2 with: data.
	
	icp iterateOnce.
	icp iterateOnce.
	icp iterateOnce.
	icp iterateOnce.
	icp iterateOnce.
	
	data2Copy := icp tfMatrix applyToCollection: data2Copy.
	
	icp outputA doWithIndex: [ :p :index |
		self assert: (( p dist: (data2Copy at: index)) < epsilon).
	].

]
