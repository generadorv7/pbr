local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local datosCasaMemoria = {}
local nombreArchivo = "CodebyHouseData.json"
local nombreProgreso = "CodebyProgress.txt"

local LIMITE_TAMANO_MAXIMO = 50.00 
local BLOQUE_A_SALTAR = 0 

-- [ VARIABLES DE PAUSA MULTI-SERVIDOR ]
local bloqueActualIndex = 1
local construccionPausada = false
local construyendo = false

local grabandoNativo = false
local paquetesGrabados = 0
local logNativo = "--- CODEBY DEBUG: DEEP SNIFFER ---\n"

-- [ CODEBY DATA MAP EXACTO Y COMPLETO ]
local MenuModels = {
    ["Bombillograndote"] = {Mesh = "rbxassetid://80763177000182", Transp = 0.00, RGB = {253, 234, 141}},
    ["Bombillograndote2"] = {Mesh = "rbxassetid://80763177000182", Transp = 0.00, RGB = {248, 248, 248}},
    ["Compresor1"] = {Mesh = "rbxassetid://91857315444027", Transp = 0.00, RGB = {163, 162, 165}},
    ["Luz Laser"] = {Mesh = "rbxassetid://6476122198", Transp = 0.00, RGB = {48, 48, 48}},
    ["Luz Sencilla"] = {Mesh = "rbxassetid://902223914", Transp = 0.00, RGB = {99, 95, 98}},
    ["Model_1"] = {Mesh = "None", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_10"] = {Mesh = "rbxassetid://15904323803", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_11"] = {Mesh = "rbxassetid://5175624767", Transp = 0.00, RGB = {237, 234, 234}},
    ["Model_12"] = {Mesh = "rbxassetid://4959643603", Transp = 0.00, RGB = {237, 234, 234}},
    ["Model_120"] = {Mesh = "rbxassetid://78070572566425", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_121"] = {Mesh = "rbxassetid://71593484877201", Transp = 0.00, RGB = {99, 95, 98}},
    ["Model_122"] = {Mesh = "rbxassetid://18699026910", Transp = 0.00, RGB = {99, 95, 98}},
    ["Model_124"] = {Mesh = "rbxassetid://131456784481615", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_13"] = {Mesh = "rbxassetid://4973527987", Transp = 0.00, RGB = {237, 234, 234}},
    ["Model_15"] = {Mesh = "rbxassetid://4992834835", Transp = 0.00, RGB = {223, 223, 222}},
    ["Model_16"] = {Mesh = "None", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_17"] = {Mesh = "None", Transp = 0.00, RGB = {248, 248, 248}},
    ["Model_18"] = {Mesh = "None", Transp = 0.00, RGB = {108, 88, 75}},
    ["Model_2"] = {Mesh = "rbxassetid://4964810548", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_20"] = {Mesh = "rbxassetid://4960045201", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_201"] = {Mesh = "rbxassetid://89952191506906", Transp = 0.00, RGB = {17, 17, 17}},
    ["Model_202"] = {Mesh = "rbxassetid://127223333706945", Transp = 0.00, RGB = {17, 17, 17}},
    ["Model_203"] = {Mesh = "rbxassetid://72783310489464", Transp = 0.00, RGB = {17, 17, 17}},
    ["Model_204"] = {Mesh = "rbxassetid://100499707672922", Transp = 0.00, RGB = {17, 17, 17}},
    ["Model_205"] = {Mesh = "rbxassetid://81815702961208", Transp = 0.00, RGB = {17, 17, 17}},
    ["Model_206"] = {Mesh = "rbxassetid://112561958658598", Transp = 0.00, RGB = {86, 36, 36}},
    ["Model_207"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_207Normal"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_208"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_209"] = {Mesh = "rbxassetid://125670082506846", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_21"] = {Mesh = "None", Transp = 0.00, RGB = {91, 93, 105}},
    ["Model_211"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_212"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_213"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_214"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_215"] = {Mesh = "rbxassetid://80951458137467", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_217"] = {Mesh = "rbxassetid://135962943031746", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_218"] = {Mesh = "rbxassetid://131099065728713", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_219"] = {Mesh = "rbxassetid://131070441620891", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_22"] = {Mesh = "rbxassetid://4955830520", Transp = 0.00, RGB = {248, 248, 248}},
    ["Model_220"] = {Mesh = "rbxassetid://75726418064380", Transp = 0.00, RGB = {17, 17, 17}},
    ["Model_222"] = {Mesh = "rbxassetid://109110714180197", Transp = 0.00, RGB = {17, 17, 17}},
    ["Model_223"] = {Mesh = "rbxassetid://131428740306084", Transp = 0.00, RGB = {255, 204, 153}},
    ["Model_224"] = {Mesh = "rbxassetid://97270779446964", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_225"] = {Mesh = "rbxassetid://133491062934863", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_226"] = {Mesh = "rbxassetid://82843146189169", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_227"] = {Mesh = "rbxassetid://98282150426104", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_228"] = {Mesh = "rbxassetid://113798783261877", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_229"] = {Mesh = "rbxassetid://101557849600680", Transp = 0.00, RGB = {255, 204, 153}},
    ["Model_230"] = {Mesh = "rbxassetid://85754202669535", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_231"] = {Mesh = "rbxassetid://72762450970148", Transp = 0.00, RGB = {0, 32, 96}},
    ["Model_232"] = {Mesh = "rbxassetid://134482887162056", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_233"] = {Mesh = "rbxassetid://103509704571550", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_234"] = {Mesh = "rbxassetid://112786378585124", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_235"] = {Mesh = "rbxassetid://128136019834335", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_236"] = {Mesh = "rbxassetid://137063752228023", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_237"] = {Mesh = "rbxassetid://70884061339178", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_238"] = {Mesh = "rbxassetid://95180002245999", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_239"] = {Mesh = "rbxassetid://112420531002502", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_24"] = {Mesh = "rbxassetid://4997610993", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_240"] = {Mesh = "rbxassetid://128424020653192", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_243"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_244"] = {Mesh = "rbxassetid://92737115380657", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_245"] = {Mesh = "rbxassetid://77064342898196", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_246"] = {Mesh = "rbxassetid://124996747478831", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_247"] = {Mesh = "rbxassetid://73452007372376", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_248"] = {Mesh = "rbxassetid://100784187710701", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_249"] = {Mesh = "rbxassetid://111024425643816", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_25"] = {Mesh = "rbxassetid://70492180320167", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_26"] = {Mesh = "rbxassetid://115751207100758", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_27"] = {Mesh = "rbxassetid://86827290088092", Transp = 0.00, RGB = {248, 248, 248}},
    ["Model_28"] = {Mesh = "rbxassetid://115751207100758", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_29"] = {Mesh = "rbxassetid://74774272998106", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_3"] = {Mesh = "rbxassetid://5050337353", Transp = 0.00, RGB = {223, 223, 222}},
    ["Model_30"] = {Mesh = "rbxassetid://108863311550307", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_31"] = {Mesh = "rbxassetid://128894726651723", Transp = 0.00, RGB = {17, 17, 17}},
    ["Model_32"] = {Mesh = "rbxassetid://81453462742445", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_33"] = {Mesh = "rbxassetid://140118843552946", Transp = 0.00, RGB = {159, 161, 172}},
    ["Model_34"] = {Mesh = "rbxassetid://72660815152869", Transp = 0.00, RGB = {159, 161, 172}},
    ["Model_35"] = {Mesh = "rbxassetid://6885159272", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_36"] = {Mesh = "rbxassetid://4969101832", Transp = 0.15, RGB = {99, 95, 98}},
    ["Model_37"] = {Mesh = "rbxassetid://4972928808", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_38"] = {Mesh = "rbxassetid://5066033835", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_39"] = {Mesh = "rbxassetid://4952232972", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_4"] = {Mesh = "rbxassetid://5039792902", Transp = 0.00, RGB = {117, 0, 0}},
    ["Model_40"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_401"] = {Mesh = "rbxassetid://86603860215468", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_402"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_403"] = {Mesh = "None", Transp = 0.00, RGB = {248, 248, 248}},
    ["Model_404"] = {Mesh = "None", Transp = 0.00, RGB = {248, 248, 248}},
    ["Model_405"] = {Mesh = "None", Transp = 0.00, RGB = {248, 248, 248}},
    ["Model_406"] = {Mesh = "None", Transp = 0.00, RGB = {248, 248, 248}},
    ["Model_407"] = {Mesh = "None", Transp = 0.00, RGB = {248, 248, 248}},
    ["Model_408"] = {Mesh = "None", Transp = 0.00, RGB = {248, 248, 248}},
    ["Model_409"] = {Mesh = "None", Transp = 0.00, RGB = {248, 248, 248}},
    ["Model_41"] = {Mesh = "rbxassetid://5007394989", Transp = 0.00, RGB = {159, 161, 172}},
    ["Model_410"] = {Mesh = "rbxassetid://12474270128", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_411"] = {Mesh = "rbxassetid://16176948658", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_412"] = {Mesh = "rbxassetid://72403459600797", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_413"] = {Mesh = "rbxassetid://111684278830545", Transp = 0.00, RGB = {199, 172, 120}},
    ["Model_414"] = {Mesh = "rbxassetid://86184753859587", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_415"] = {Mesh = "rbxassetid://87023752251833", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_416"] = {Mesh = "rbxassetid://139201190357549", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_417"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_418"] = {Mesh = "rbxassetid://92137715626911", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_419"] = {Mesh = "rbxassetid://132267138928086", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_42"] = {Mesh = "rbxassetid://5007279201", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_420"] = {Mesh = "rbxassetid://86761923302083", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_421"] = {Mesh = "rbxassetid://137761590021408", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_422"] = {Mesh = "rbxassetid://89381482249771", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_423"] = {Mesh = "rbxassetid://85391337207845", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_424"] = {Mesh = "rbxassetid://84799836351447", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_425"] = {Mesh = "rbxassetid://126017611691210", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_426"] = {Mesh = "rbxassetid://94528970984080", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_427"] = {Mesh = "rbxassetid://93058400317823", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_428"] = {Mesh = "rbxassetid://121660410820247", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_429"] = {Mesh = "rbxassetid://136092431583342", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_43"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_430"] = {Mesh = "rbxassetid://93004234009750", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_431"] = {Mesh = "rbxassetid://75083848465950", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_432"] = {Mesh = "rbxassetid://74022204380618", Transp = 0.00, RGB = {99, 95, 98}},
    ["Model_433"] = {Mesh = "rbxassetid://97625567993314", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_434"] = {Mesh = "rbxassetid://135195943601177", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_435"] = {Mesh = "rbxassetid://111064275742100", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_436"] = {Mesh = "rbxassetid://124992065594676", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_437"] = {Mesh = "rbxassetid://83099253240627", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_438"] = {Mesh = "rbxassetid://113435215390973", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_439"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["Model_44"] = {Mesh = "rbxassetid://5133663308", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_440"] = {Mesh = "rbxassetid://128965150851740", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_441"] = {Mesh = "rbxassetid://86824178634019", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_442"] = {Mesh = "rbxassetid://84649589470189", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_45"] = {Mesh = "None", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_450"] = {Mesh = "rbxassetid://13494055604", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_451"] = {Mesh = "rbxassetid://79362097400567", Transp = 0.00, RGB = {248, 248, 248}},
    ["Model_4511"] = {Mesh = "rbxassetid://79362097400567", Transp = 0.00, RGB = {248, 248, 248}},
    ["Model_46"] = {Mesh = "rbxassetid://5064756883", Transp = 0.00, RGB = {99, 95, 98}},
    ["Model_47"] = {Mesh = "rbxassetid://92212227603441", Transp = 0.00, RGB = {17, 17, 17}},
    ["Model_5"] = {Mesh = "rbxassetid://6602397746", Transp = 0.00, RGB = {231, 231, 236}},
    ["Model_501"] = {Mesh = "rbxassetid://117927092852489", Transp = 0.00, RGB = {117, 0, 0}},
    ["Model_502"] = {Mesh = "rbxassetid://85352373292408", Transp = 0.00, RGB = {91, 93, 105}},
    ["Model_503"] = {Mesh = "rbxassetid://77458393958523", Transp = 0.00, RGB = {91, 93, 105}},
    ["Model_504"] = {Mesh = "rbxassetid://100716207139167", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_505"] = {Mesh = "rbxassetid://85062724520788", Transp = 0.00, RGB = {17, 17, 17}},
    ["Model_506"] = {Mesh = "rbxassetid://134968853900452", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_507"] = {Mesh = "rbxassetid://128853698632293", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_508"] = {Mesh = "rbxassetid://133895096498225", Transp = 0.00, RGB = {202, 203, 209}},
    ["Model_509"] = {Mesh = "rbxassetid://107942089842966", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_510"] = {Mesh = "rbxassetid://98120593618404", Transp = 0.00, RGB = {81, 81, 81}},
    ["Model_511"] = {Mesh = "rbxassetid://80645079807858", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_512"] = {Mesh = "rbxassetid://118028453787690", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_513"] = {Mesh = "rbxassetid://79889964181552", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_514"] = {Mesh = "rbxassetid://140014518309799", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_515"] = {Mesh = "rbxassetid://130127606178376", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_516"] = {Mesh = "rbxassetid://75653936542393", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_517"] = {Mesh = "rbxassetid://138570436153349", Transp = 0.00, RGB = {91, 154, 76}},
    ["Model_518"] = {Mesh = "rbxassetid://95794445854549", Transp = 0.00, RGB = {204, 142, 105}},
    ["Model_519"] = {Mesh = "rbxassetid://70492763572605", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_521"] = {Mesh = "rbxassetid://140168585827312", Transp = 0.00, RGB = {255, 0, 0}},
    ["Model_522"] = {Mesh = "rbxassetid://106129785104434", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_523"] = {Mesh = "rbxassetid://103695543952886", Transp = 0.00, RGB = {13, 105, 172}},
    ["Model_6"] = {Mesh = "rbxassetid://126119495968334", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_600"] = {Mesh = "rbxassetid://92801927415170", Transp = 0.00, RGB = {0, 143, 156}},
    ["Model_601"] = {Mesh = "rbxassetid://136315174872696", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_602"] = {Mesh = "rbxassetid://101715598740241", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_603"] = {Mesh = "rbxassetid://106037619856733", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_604"] = {Mesh = "rbxassetid://80980675418606", Transp = 0.00, RGB = {27, 42, 53}},
    ["Model_605"] = {Mesh = "rbxassetid://101888726862228", Transp = 0.00, RGB = {175, 148, 131}},
    ["Model_606"] = {Mesh = "rbxassetid://139693143759150", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_7"] = {Mesh = "rbxassetid://121735512198668", Transp = 0.00, RGB = {159, 161, 172}},
    ["Model_8"] = {Mesh = "rbxassetid://1538080694", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_9"] = {Mesh = "rbxassetid://3065385037", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_90"] = {Mesh = "rbxassetid://9648592256", Transp = 0.00, RGB = {180, 128, 255}},
    ["Model_91"] = {Mesh = "rbxassetid://7220723753", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_92"] = {Mesh = "None", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_Bath_1"] = {Mesh = "rbxassetid://72600209754274", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_10"] = {Mesh = "rbxassetid://95773890196106", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_11"] = {Mesh = "rbxassetid://80362761534233", Transp = 0.00, RGB = {99, 95, 98}},
    ["Model_Bath_12"] = {Mesh = "rbxassetid://122933697867687", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_13"] = {Mesh = "rbxassetid://139481493920578", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_14"] = {Mesh = "rbxassetid://83662581582939", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_15"] = {Mesh = "rbxassetid://87772436100055", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_16"] = {Mesh = "rbxassetid://130756124984257", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_17"] = {Mesh = "rbxassetid://100985423557297", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_18"] = {Mesh = "rbxassetid://111278974199315", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_19"] = {Mesh = "rbxassetid://132473140453085", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_Bath_2"] = {Mesh = "rbxassetid://106113224839023", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_20"] = {Mesh = "rbxassetid://135925718810036", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_21"] = {Mesh = "rbxassetid://129776861541050", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_22"] = {Mesh = "rbxassetid://71951785252042", Transp = 0.00, RGB = {91, 93, 105}},
    ["Model_Bath_23"] = {Mesh = "rbxassetid://116269430415284", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_24"] = {Mesh = "rbxassetid://9813480362", Transp = 0.00, RGB = {27, 42, 53}},
    ["Model_Bath_3"] = {Mesh = "rbxassetid://96748256944503", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_4"] = {Mesh = "rbxassetid://89171283388693", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_5"] = {Mesh = "rbxassetid://109650157048514", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_6"] = {Mesh = "rbxassetid://70905362721804", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_7"] = {Mesh = "rbxassetid://76539456498238", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_Bath_8"] = {Mesh = "rbxassetid://109986769068115", Transp = 0.00, RGB = {90, 76, 66}},
    ["Model_Bath_9"] = {Mesh = "rbxassetid://85933500925065", Transp = 0.00, RGB = {163, 162, 165}},
    ["Model_toilet2"] = {Mesh = "rbxassetid://111753869964523", Transp = 0.00, RGB = {163, 162, 165}},
    ["Mueble Cocina Clasico de Madera"] = {Mesh = "rbxassetid://5055653462", Transp = 0.00, RGB = {90, 76, 66}},
    ["Mueble Cocina Clasico de Madera2"] = {Mesh = "None", Transp = 0.00, RGB = {90, 76, 66}},
    ["Velita"] = {Mesh = "rbxassetid://11337009499", Transp = 0.00, RGB = {163, 162, 165}},
    ["cajita"] = {Mesh = "None", Transp = 0.00, RGB = {255,255,255}},
    ["fan o air vintage table fan "] = {Mesh = "rbxassetid://3483639725", Transp = 0.00, RGB = {163, 162, 165}},
    ["model_paper_toilet"] = {Mesh = "rbxassetid://80260117969503", Transp = 0.00, RGB = {163, 162, 165}},
    ["model_toilet4"] = {Mesh = "rbxassetid://117753320258816", Transp = 0.00, RGB = {163, 162, 165}},

    -- [ BLOQUES FÍSICOS SIN MESH ]
    ["wedge_tile"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["part_cube"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["part_cube_brick"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["part_cube_ceramica"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["part_cube_glass"] = {Mesh = "None", Transp = 0.50, RGB = {163, 162, 165}},
    ["part_cube_metal"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["part_cube_neon"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["part_cube_wood"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["part_water"] = {Mesh = "None", Transp = 0.30, RGB = {81, 129, 165}},
    ["wedge"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["wedge_Wood"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["wedge_brick"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["wedge_metal"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["wedge_neon"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["part_Grass1"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["part_Arena"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["part_BricksRed"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["part_cobblestone"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}},
    ["wedge_Ladrillo"] = {Mesh = "None", Transp = 0.00, RGB = {163, 162, 165}}
}

-- [ LA MAGIA DE DETECCIÓN HÍBRIDA ]
local function identificarModeloExacto(mueble, parteVisible)
    local meshIdDetectado = nil
    if parteVisible:IsA("MeshPart") then
        meshIdDetectado = parteVisible.MeshId
    else
        local meshObj = parteVisible:FindFirstChildWhichIsA("SpecialMesh") or mueble:FindFirstChildWhichIsA("SpecialMesh", true)
        if meshObj then meshIdDetectado = meshObj.MeshId end
    end

    if meshIdDetectado and meshIdDetectado ~= "" then
        local numDetectado = string.match(meshIdDetectado, "%d+") 
        if numDetectado then
            for nombre, data in pairs(MenuModels) do
                if data.Mesh ~= "None" then
                    local numDiccionario = string.match(data.Mesh, "%d+")
                    if numDiccionario and numDiccionario == numDetectado then
                        return nombre
                    end
                end
            end
        end
    end

    local isWedge = parteVisible:IsA("WedgePart")
    local mat = parteVisible.Material
    local trans = parteVisible.Transparency

    if isWedge then
        if mat == Enum.Material.Wood or mat == Enum.Material.WoodPlanks then return "wedge_Wood" end
        if mat == Enum.Material.Brick then return "wedge_brick" end
        if mat == Enum.Material.Metal or mat == Enum.Material.CorrodedMetal then return "wedge_metal" end
        if mat == Enum.Material.Neon then return "wedge_neon" end
        if mat == Enum.Material.Cobblestone then return "wedge_Ladrillo" end
        return "wedge_tile" 
    else
        if trans >= 0.4 then return "part_cube_glass" end
        if trans > 0.1 and trans < 0.4 then return "part_water" end
        if mat == Enum.Material.Brick then return "part_cube_brick" end
        if mat == Enum.Material.Wood or mat == Enum.Material.WoodPlanks then return "part_cube_wood" end
        if mat == Enum.Material.Metal or mat == Enum.Material.CorrodedMetal or mat == Enum.Material.DiamondPlate then return "part_cube_metal" end
        if mat == Enum.Material.Neon then return "part_cube_neon" end
        if mat == Enum.Material.Grass then return "part_Grass1" end
        if mat == Enum.Material.Sand then return "part_Arena" end
        if mat == Enum.Material.Cobblestone then return "part_cobblestone" end
        
        return "part_cube"
    end
end

local function obtenerParteVisible(mueble)
    local mejorParte = nil
    local volumenMax = 0
    for _, p in ipairs(mueble:GetDescendants()) do
        if p:IsA("BasePart") and p.Transparency < 1 then 
            local vol = p.Size.X * p.Size.Y * p.Size.Z
            if vol > volumenMax then 
                volumenMax = vol; mejorParte = p 
            end
        end
    end
    if not mejorParte then mejorParte = mueble:FindFirstChildWhichIsA("BasePart", true) end
    return mejorParte
end

-- ==========================================
-- GUI CODEBY ELITE (REDISEÑADA Y LIMPIA)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")

local ScanBtn = Instance.new("TextButton")
local LoadBtn = Instance.new("TextButton")
local BuildBtn = Instance.new("TextButton")
local PauseBtn = Instance.new("TextButton") 
local NativeSniffBtn = Instance.new("TextButton") 

local StatusLabel = Instance.new("TextLabel")
local MemoryLabel = Instance.new("TextLabel")
local Corner = Instance.new("UICorner")
local CloseBtn = Instance.new("TextButton")
local OpenBtn = Instance.new("TextButton")

ScreenGui.Name = "Codeby"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

OpenBtn.Name = "OpenCodeby"
OpenBtn.Parent = ScreenGui
OpenBtn.Size = UDim2.new(0, 80, 0, 30)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
OpenBtn.Text = "By:Codeby"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 6)

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -160)
MainFrame.Size = UDim2.new(0, 240, 0, 300) 
MainFrame.Active = true
MainFrame.Draggable = true
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "CODEBY ELITE V59"
Title.TextColor3 = Color3.fromRGB(150, 0, 255)
Title.TextSize = 18

CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = MainFrame
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

ScanBtn.Parent = MainFrame
ScanBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
ScanBtn.Position = UDim2.new(0.1, 0, 0.15, 0)
ScanBtn.Size = UDim2.new(0.8, 0, 0.11, 0)
ScanBtn.Text = "1. ESCANEAR Y GUARDAR"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", ScanBtn)

LoadBtn.Parent = MainFrame
LoadBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
LoadBtn.Position = UDim2.new(0.1, 0, 0.29, 0)
LoadBtn.Size = UDim2.new(0.8, 0, 0.11, 0)
LoadBtn.Text = "2. CARGAR JSON"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", LoadBtn)

BuildBtn.Parent = MainFrame
BuildBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
BuildBtn.Position = UDim2.new(0.1, 0, 0.43, 0)
BuildBtn.Size = UDim2.new(0.8, 0, 0.11, 0)
BuildBtn.Text = "3. CONSTRUIR (Abajo->Arriba)"
BuildBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", BuildBtn)

PauseBtn.Parent = MainFrame
PauseBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
PauseBtn.Position = UDim2.new(0.1, 0, 0.57, 0)
PauseBtn.Size = UDim2.new(0.8, 0, 0.11, 0)
PauseBtn.Text = "PAUSAR CONSTRUCCION"
PauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", PauseBtn)

NativeSniffBtn.Parent = MainFrame
NativeSniffBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
NativeSniffBtn.Position = UDim2.new(0.1, 0, 0.71, 0)
NativeSniffBtn.Size = UDim2.new(0.8, 0, 0.11, 0)
NativeSniffBtn.Text = "SNIFFER FANTASMA"
NativeSniffBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", NativeSniffBtn)

MemoryLabel.Parent = MainFrame
MemoryLabel.BackgroundTransparency = 1
MemoryLabel.Position = UDim2.new(0, 0, 0.84, 0)
MemoryLabel.Size = UDim2.new(1, 0, 0, 20)
MemoryLabel.Text = "Memoria: Vacia"
MemoryLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.89, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Text = "Pon bloque manual."
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenBtn.Visible = false end)

-- ==========================================
-- HOOK FANTASMA PARALELO
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlotSystem = ReplicatedStorage.Connections.Remotes.PlotSystem
local Terrenos = game.Workspace:WaitForChild("Terrenos")
local sessionToken, currentSequence, robado = nil, 0, false

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if method == "InvokeServer" or method == "FireServer" then
        local args = {...}
        local remoteName = self.Name
        
        task.spawn(function()
            pcall(function()
                if grabandoNativo and (string.find(remoteName, "Plot") or string.find(remoteName, "Build") or string.find(remoteName, "Furn")) then
                    paquetesGrabados = paquetesGrabados + 1
                    local details = "\n["..paquetesGrabados.."] Remoto: " .. remoteName .. " | Metodo: " .. method .. "\n"
                    for i, v in ipairs(args) do
                        local tipo = typeof(v)
                        if tipo == "Vector3" then
                            details = details .. string.format("[%d] (Size/Pos): (%.2f, %.2f, %.2f)\n", i, v.X, v.Y, v.Z)
                        elseif tipo == "CFrame" then
                            local x, y, z = v:GetComponents()
                            details = details .. string.format("[%d] CFrame Pos: (%.2f, %.2f, %.2f)\n", i, x, y, z)
                        else
                            details = details .. "[" .. i .. "] (" .. tipo .. "): " .. tostring(v) .. "\n"
                        end
                    end
                    details = details .. "----------------------"
                    logNativo = logNativo .. details
                    
                    if paquetesGrabados >= 6 then
                        grabandoNativo = false
                        if setclipboard then setclipboard(logNativo) end
                        StatusLabel.Text = "¡LOG COPIADO!"
                        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                        NativeSniffBtn.Text = "SNIFFER FANTASMA"
                        NativeSniffBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
                    end
                end

                if remoteName == "PlotSystem" then
                    if type(args[1]) == "string" and type(args[2]) == "number" then
                        local accion = tostring(args[3])
                        if accion == "placeFurn" or accion == "scaleFurniture" then
                            if not robado then
                                sessionToken = args[1]
                                currentSequence = args[2]
                                robado = true
                                StatusLabel.Text = "FANTASMA ACTIVO By:Codeby"
                                StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
                            end
                        end
                    end
                end
            end)
        end)
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- ==========================================
-- LÓGICAS DE BOTONES (SISTEMA DE PAUSA MULTI-SV)
-- ==========================================
PauseBtn.MouseButton1Click:Connect(function()
    if construyendo and not construccionPausada then
        construccionPausada = true
        StatusLabel.Text = "PAUSANDO..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        if writefile then
            writefile(nombreProgreso, tostring(bloqueActualIndex))
        end
    end
end)

NativeSniffBtn.MouseButton1Click:Connect(function()
    grabandoNativo = true
    paquetesGrabados = 0
    logNativo = "--- CODEBY DEBUG: DEEP SNIFFER ---\n"
    NativeSniffBtn.Text = "GRABANDO..."
    NativeSniffBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
end)

local function obtenerMiPlotFolder()
    local miPos = (LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position) or Vector3.new(0,0,0)
    local masCercano, miFolder = math.huge, nil
    for _, folder in ipairs(Terrenos:GetChildren()) do
        local base = folder:FindFirstChildWhichIsA("BasePart")
        if base and (base.Position - miPos).Magnitude < masCercano then 
            masCercano = (base.Position - miPos).Magnitude; miFolder = folder 
        end
    end
    return miFolder
end

local function obtenerTerrenoVecinoMasCercano(miTerreno)
    local miPos = (LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position) or Vector3.new(0,0,0)
    local terrenoObjetivo = nil
    local distMinima = math.huge
    for _, folder in ipairs(Terrenos:GetChildren()) do
        if folder ~= miTerreno then
            local base = folder:FindFirstChildWhichIsA("BasePart")
            if base then
                local d = (base.Position - miPos).Magnitude
                if d < distMinima then distMinima = d; terrenoObjetivo = folder end
            end
        end
    end
    return terrenoObjetivo
end

ScanBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        StatusLabel.Text = "Escaneando Visualmente..."; 
        local miT = obtenerMiPlotFolder()
        local obj = obtenerTerrenoVecinoMasCercano(miT) 
        if not obj then StatusLabel.Text = "No hay vecinos."; return end
        
        datosCasaMemoria = {}
        local exportData = {}
        local objBase = obj:FindFirstChildWhichIsA("BasePart")
        
        for _, m in ipairs(obj.FurnitureContainer:GetChildren()) do
            local p = obtenerParteVisible(m) 
            if p then
                local safeSize = p.Size
                local cframeRel = objBase.CFrame:Inverse() * p:GetPivot() 
                
                local nombreBloque = identificarModeloExacto(m, p)

                table.insert(datosCasaMemoria, {
                    Nombre = nombreBloque,
                    CFrameRelativo = cframeRel,
                    Size = safeSize
                })
                table.insert(exportData, {
                    Nombre = nombreBloque,
                    CFrameRelativo = {cframeRel:GetComponents()},
                    Size = {safeSize.X, safeSize.Y, safeSize.Z}
                })
            end
        end
        if writefile then
            local jsonCodificado = HttpService:JSONEncode(exportData)
            writefile(nombreArchivo, jsonCodificado)
            
            -- Resetear progreso en el nuevo escaneo
            writefile(nombreProgreso, "1")
            bloqueActualIndex = 1
            BuildBtn.Text = "3. CONSTRUIR (Abajo->Arriba)"
            StatusLabel.Text = "¡Guardado Inteligente!"
        end
        MemoryLabel.Text = "Memoria: " .. #datosCasaMemoria .. " bloques."
    end)
end)

LoadBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        if readfile and isfile and isfile(nombreArchivo) then
            local jsonDecodificado = readfile(nombreArchivo)
            local rawData = HttpService:JSONDecode(jsonDecodificado)
            datosCasaMemoria = {}
            for _, v in ipairs(rawData) do
                table.insert(datosCasaMemoria, {
                    Nombre = v.Nombre,
                    CFrameRelativo = CFrame.new(unpack(v.CFrameRelativo)),
                    Size = Vector3.new(unpack(v.Size))
                })
            end
            
            -- [ ORDENAMIENTO ABSOLUTO (Y, X, Z) PARA MULTI-SERVER ]
            table.sort(datosCasaMemoria, function(a, b)
                local posA = a.CFrameRelativo.Position
                local posB = b.CFrameRelativo.Position
                if math.abs(posA.Y - posB.Y) > 0.01 then
                    return posA.Y < posB.Y
                elseif math.abs(posA.X - posB.X) > 0.01 then
                    return posA.X < posB.X
                else
                    return posA.Z < posB.Z
                end
            end)

            -- [ CARGA DE MEMORIA DE PAUSA ]
            if isfile(nombreProgreso) then
                local savedProg = tonumber(readfile(nombreProgreso))
                if savedProg and savedProg > 1 and savedProg <= #datosCasaMemoria then
                    bloqueActualIndex = savedProg
                    BuildBtn.Text = "REANUDAR CONSTRUCCION"
                    StatusLabel.Text = "Progreso recuperado: " .. bloqueActualIndex .. "/" .. #datosCasaMemoria
                else
                    bloqueActualIndex = 1
                    BuildBtn.Text = "3. CONSTRUIR (Abajo->Arriba)"
                    StatusLabel.Text = "¡Carga Exitosa!"
                end
            else
                bloqueActualIndex = 1
                BuildBtn.Text = "3. CONSTRUIR (Abajo->Arriba)"
                StatusLabel.Text = "¡Carga Exitosa!"
            end

            MemoryLabel.Text = "Memoria: " .. #datosCasaMemoria .. " cargados."
        end
    end)
end)

-- ==========================================
-- MOTOR CONSTRUCTOR V59: PERSISTENTE Y HUMANO
-- ==========================================
BuildBtn.MouseButton1Click:Connect(function()
    if construyendo then return end
    if not robado or #datosCasaMemoria == 0 then return end
    
    task.spawn(function()
        construyendo = true
        construccionPausada = false
        BuildBtn.Text = "CONSTRUYENDO..."
        BuildBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

        local miT = obtenerMiPlotFolder()
        local miBase = miT:FindFirstChildWhichIsA("BasePart")
        local container = miT:WaitForChild("FurnitureContainer")
        
        while bloqueActualIndex <= #datosCasaMemoria do
            if construccionPausada then break end
            
            local i = bloqueActualIndex
            local data = datosCasaMemoria[i]

            if i == BLOQUE_A_SALTAR then
                task.wait(0.1)
            else
                StatusLabel.Text = "Bloque " .. i .. " / " .. #datosCasaMemoria .. "\n(" .. data.Nombre .. ")"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                local targetCF = miBase.CFrame * data.CFrameRelativo
                
                -- PASO 1: COLOCAR
                currentSequence = currentSequence + 1
                local nuevo = nil
                local conn = container.ChildAdded:Connect(function(c) nuevo = c end)
                
                task.spawn(function()
                    pcall(function() PlotSystem:InvokeServer(sessionToken, currentSequence, "placeFurn", data.Nombre, targetCF) end)
                end)
                
                local t = 0; while not nuevo and t < 2 do task.wait(0.1); t = t + 0.1 end
                conn:Disconnect()
                
                if nuevo then
                    local id = nuevo:GetAttribute("Id") or nuevo.Name
                    
                    task.wait(0.4) 
                    
                    -- PASO 2: ESTIRAR SIN PINTAR
                    currentSequence = currentSequence + 1
                    task.spawn(function()
                        pcall(function() PlotSystem:InvokeServer(sessionToken, currentSequence, "scaleFurniture", id, targetCF, data.Size) end)
                    end)
                end
                
                task.wait(0.5) 
                if i % 10 == 0 then task.wait(1.5) end
            end

            -- Si no se ha pausado a la fuerza, avanza y auto-guarda
            if not construccionPausada then
                bloqueActualIndex = bloqueActualIndex + 1
                -- Auto-Save cada 5 bloques en caso de Crash/Desconexión del juego
                if bloqueActualIndex % 5 == 0 and writefile then
                    writefile(nombreProgreso, tostring(bloqueActualIndex))
                end
            end
        end

        construyendo = false
        BuildBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)

        if construccionPausada then
            StatusLabel.Text = "PAUSADO EN: " .. bloqueActualIndex .. " / " .. #datosCasaMemoria
            StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            BuildBtn.Text = "REANUDAR CONSTRUCCION"
        else
            StatusLabel.Text = "¡CASA CONSTRUIDA By:Codeby!"
            StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
            BuildBtn.Text = "3. CONSTRUIR (Abajo->Arriba)"
            bloqueActualIndex = 1 
            if writefile then writefile(nombreProgreso, "1") end
        end
    end)
end)