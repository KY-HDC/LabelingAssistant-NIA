//
//  MainVC.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 2018. 10. 10..
//  Copyright © 2018년 uBiz Information Technology. All rights reserved.
//

import UIKit

var ImageList:[ImageInfo] = []
var LabelList:LabelInfoList = LabelInfoList()
func LabelingDoneCount() -> Int {
    var count = 0
    for item in ImageList {
        if let isDone = item.isLabelingDone {
            if (isDone) { count = count + 1 }
        }
    }
    return count
}

class LabelingVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var reviewSettingButton: UIButton!
    // 히든용 뷰를 하나 만들어서 제스처에 사용
    let hiddenView = UIView()

    // 이미지 상단 정보
    @IBOutlet var signedUserNameLabel: UILabel!
    @IBOutlet var projectNameLabel: UILabel!
    @IBOutlet var labelingOrderLabel: UILabel!
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var imageIDLabel: UILabel!
    @IBOutlet var imageFileNameLabel: UILabel!
    @IBOutlet var piNameLabel: UILabel!
    @IBOutlet var piSexLabel: UILabel!
    @IBOutlet var piAgeLabel: UILabel!
    @IBOutlet var imageSeqLabel: UILabel!
    @IBOutlet var imageViewSizeLabel: UILabel!

    @IBOutlet var topInfoView: UIView!
    @IBOutlet var isDropSwitch: UISwitch!
    @IBOutlet var dropSwitchView: UIView!
    
    // 이미지
    @IBOutlet var EditingImage: UIImageView!
    @IBOutlet var ScrollImage: UIScrollView!

    // 라벨 표시 테이블
    @IBOutlet var tableViewLabelLeft: UITableView!
    @IBOutlet var tableViewLabelRight: UITableView!

    // 화면 하단 버튼
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var undoButton: UIButton!
    @IBOutlet var redoButton: UIButton!
    @IBOutlet var trashButton: UIButton!

    @IBOutlet weak var fastSearchView: UIView!
    @IBOutlet weak var firstFastButton: UIButton!
    @IBOutlet weak var leftFastButton: UIButton!
    @IBOutlet weak var rightFastButton: UIButton!
    @IBOutlet weak var lastFastButton: UIButton!

    @IBOutlet var firstButton: UIButton!
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var reloadButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var lastButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    var isTotalExplore:Bool = true
    var fastSearch:Bool = false

    // 이미지 하단 정보
    @IBOutlet var editModeImage: UIImageView!
    @IBOutlet var editModeLabel: UILabel!
    @IBOutlet var selectedMarkInfo: UILabel!
    @IBOutlet var touchPosition: UILabel!
    @IBOutlet var isDoneImage: UIImageView!
    @IBOutlet var isMarkEnabledImage: UIImageView!
    
    @IBOutlet var labelLeftTitle: UILabel!
    @IBOutlet var labelRightTitle: UILabel!
    
    @IBOutlet var bottomEditMarkInfoView: UIView!
    
    // 이미지 라벨링 갯수 저장용
    var total_count = 0     // 전체 이미지 갯수
    var complete_count = 0  // 완료 이미지 갯수
    var more_image = "N"    // 이미지가 더 있는지...

    // 이미지 네비게이션 버튼 중 무엇이 선택되었는가
    // P:Prev, N:Next, L:Last, F:First, R:Random(랜덤은 서버 프로시저에서 차수가 1이 아닌 경우 체크하여 수행)
    var FPNLFlag: String = "F"

    var errorMessage: String = "Error~"

    // Marking 활성화 여부
    var markEnabled = false

    // ------------------------------------------------------------------------------
    // color
    // ------------------------------------------------------------------------------
    let defaultCellBackgroundColor = UIColor.init(red: 232/255.0, green: 232/255.0, blue: 232/255.0, alpha: 1.0)
    let defaultCellTextColor = UIColor.black
    let selectedCellBackgroundColor = UIColor.orange
    let selectedCellTextColor = UIColor.white

    var labelsLeft = ["Negative", "Positive"]
    var labelsRight = ["Negative", "Positive"]
    
    var imageInfo:ImageInfo = ImageInfo()
    
    var selectedLabelLeftIndex = -1
    var selectedLabelRightIndex = -1
    var tableViewCellHeight = 10

    var markShapeId = 0                             // ID
    var arrayMarkShapeLayer = [MarkShape]()
    var undoMarkStack = Stack<UndoRedo>()
    var redoMarkStack = Stack<UndoRedo>()

    // 마크의 좌표를 아래 변수의 상대값으로 저장
    let basex = 10000
    let basey = 10000

    // ------------------------- 메뉴 처리/Segue 처리  from ----------------------------------
    // menu 버튼 tab하면 메뉴 뷰 나오게 함
    let menuTransition = SlideMenuInTransition()
    var menuViewController:MenuVC = MenuVC()
    
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        
        menuViewController.didTopMenuType = { menuType in
            print(menuType)
            self.transitionToNewContent(menuType)
        }
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self // transitioningdeligate 설정
        present(menuViewController, animated: true)
        
        // 홈화면 위를 흐리게 하기 위해서 dimming view를 사용
        // dimming view를 탭하면 메뉴 뷰 사라지게 함
        setupDimmingViewTapGestureRecognizer(view: menuTransition.dimmingView)
        
    }
    
    // dimming view를 탭하면 실행할 seclector 지정
    func setupDimmingViewTapGestureRecognizer(view:UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    // dimming view tab selector
    @objc func dimmingViewTapped(_ gesture: UITapGestureRecognizer) {
        menuViewController.didTopMenuType?(MenuType.nothing)
        menuViewController.dismiss(animated: true, completion: nil)
        checkHiddenView()
    }
    
    func transitionToNewContent(_ menuType: MenuType) {
        
        switch menuType {
        case .login:
            self.performSegue(withIdentifier: "segueLoginOut", sender: self)
            break
        case .projectList:
            self.performSegue(withIdentifier: "segueProjectList", sender: self)
            break
        case .help:
            self.performSegue(withIdentifier: "segueHelp", sender: self)
            break
        case .about:
            self.performSegue(withIdentifier: "segueAbout", sender: self)
            break
        case .labeling:
            self.performSegue(withIdentifier: "segueLabeling", sender: self)
            break
        case .nothing:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueLoginOut" {
        }
        else if segue.identifier == "segueProjectList" {
            print("loading segueProjectList")
            //let projectVC = (segue.destination as! ProjectVC)
        }
        else if segue.identifier == "segueHelp" {
        }
        else if segue.identifier == "segueAbout" {
        }
        else if segue.identifier == "segueLabeling" {
        }
        else if segue.identifier == "segueReferImages" {
            guard let imageID = ImageList[currentImageIndex].id else { return }

            // 네비게이션을 통해서 이동할때
            let navi = segue.destination as? UINavigationController
            let slideReferImagesVC = navi?.viewControllers.first as! SlideReferImagesVC
            slideReferImagesVC.projectCode = WorkingProjectCode
            slideReferImagesVC.imageId = imageID
            slideReferImagesVC.imgArr = referImages

            // 네비게이션을 통하지 않고 바로 ViewController로 이동할때
//            let slideReferImagesVC = segue.destination as! SlideReferImagesVC
//            slideReferImagesVC.projectCode = WorkingProjectCode
//            slideReferImagesVC.imageId = imageID
//            slideReferImagesVC.imgArr = referImages
        }
    }
    
    var displayMenuView = false
    @IBAction func returnFromsegueAction(segue : UIStoryboardSegue) {
        displayMenuView = true
        
        isNewLogined = false
        isNewProjectBegan = false

        if let id = segue.identifier {
            print("returnFromsegueAction (segue identifier) : ", id)
            if (id == "unwindFromNewProject") {
                isFromProjectMenu = true
                isNewProjectBegan = true
                displayMenuView = false
                
                //새로 프로젝트가 시작되었으면 설정 값을 초기화
                initLabelingSettingItem()
                
                // 다시 들어오면 무조건 true 20190606
                setExploreButtonsOnOff(onOff: true)

            }
            else if (id == "unwindFromProjectList") {
                isFromProjectMenu = true
                isNewProjectBegan = false
            }
            else if (id == "unwindFromNewLogin") {
                isFromLoginMenu = true
                isNewLogined = true
                displayMenuView = false
            }
            else if (id == "unwindFromLoginOut") {
                isFromLoginMenu = true
                isNewLogined = false
            }
            else if (id == "unwindFromReferImages") {
                displayMenuView = false
            }
            else if (id == "unwindFromLabelingSetting") {
                isFromSettingMenu = true
                displayMenuView = false
            }
        }
    }

    // ------------------------- 메뉴 처리/Segue 처리 to ----------------------------------

    
    // 검토 설정 begin
    
    
    @objc func didTapReviewSetting(_ sender: UIButton) {

//        getLabelMasterWithResult()
        performSegue(withIdentifier: "segueReviewSetting", sender: self)
    }
    
    func getLabelMasterWithResult() {
        // ------------------------------------------------
        // 스피너 시작
        // ------------------------------------------------
        let child = SpinnerViewController()
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        DoEvents(f: 0.05)
        
        if (!selectLabelListWithResult()) {
            print("selectLabelListWithResult() call error")
        }
        // ------------------------------------------------
        // 스피너 종료
        // ------------------------------------------------
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    func initLabelingSettingItem() {
        IsReviewMode = false
        IncludeLabelingDoneImage = true

        fastSearchView.isHidden = false // 패스트 검색 버튼 보이게 .. 리뷰모드에서는 안보이게...

        isTotalExplore = IncludeLabelingDoneImage
        if (isTotalExplore) { setExploreButtonsOnOff(onOff: true) }

        LeftIndexOnReviewMode = -1
        RightIndexOnReviewMode = -1
        
//        currentModeTitleLabel.text = ""
//        currentModeTitleLabel.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.thin)
//        currentModeTitleLabel.textColor = UIColor.black
        self.title = "라벨링 메인"
    }
    
    func setLabelingSettingItem() {
        isTotalExplore = IncludeLabelingDoneImage
        if (isTotalExplore) { setExploreButtonsOnOff(onOff: true) }

        if (IsReviewMode) {
//            currentModeTitleLabel.text = "작업 모드 : 리뷰 모드"
//            currentModeTitleLabel.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.regular)
//            currentModeTitleLabel.textColor = UIView().tintColor
//            self.title = "라벨링 메인 (리뷰 모드)"
            
            self.title = "라벨링 메인 (리뷰 모드)"
            
            naviBarBlinkStart()
        }
//        else if (IncludeLabelingDoneImage) {
//            currentModeTitleLabel.text = "작업 모드 : 전체 탐색 모드"
//            currentModeTitleLabel.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.regular)
//            currentModeTitleLabel.textColor = UIColor.orange
//            self.title = "라벨링 메인 (전체 탐색 모드)"
//        }
        else {
//            currentModeTitleLabel.text = ""
//            currentModeTitleLabel.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.thin)
//            currentModeTitleLabel.textColor = UIColor.black
//            self.title = "라벨링 메인"
            self.title = "라벨링 메인"
            
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            naviBarBlinkStop()
        }
    }
    
    // 검토 설정 end
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "라벨링 메인"
        let reloadItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Reload-50"), style: .plain, target: self, action: #selector(reloadImageList(_:)))
        //let loadSettingViewItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Setting-50"), style: .plain, target: self, action: #selector(didTapReviewSetting(_:)))
        let loadSettingViewItem  = UIBarButtonItem(title: "리뷰모드설정", style: .plain, target: self, action: #selector(didTapReviewSetting(_:)))
        self.navigationItem.rightBarButtonItems = [reloadItem, loadSettingViewItem]

        // 히든용 뷰를 하나 만들어서 제스처에 사용
        setHiddenView(view: hiddenView)
        checkHiddenView()
        
//        WhenReceiveNoti(self, #selector(whenLoginOut), noti: EnumMyNoti.LoginOutEvent)
//        WhenReceiveNoti(self, #selector(whenLabelingBeginEnd), noti: EnumMyNoti.LabelingBeginEndEvent)
//        WhenReceiveNoti(self, #selector(showLoginView), noti: EnumMyNoti.MenuLoginTapped)
//        WhenReceiveNoti(self, #selector(showProjectSettingView), noti: EnumMyNoti.MenuProjectSettingTapped)

        initObjectsInView()
        initTableViewProperty()
        initImageViewProperty()
        initGesture()
        initLabelingSettingItem()
        
    }
    
    @objc func showLoginView() {
        performSegue(withIdentifier: "segueLogin", sender: nil)
    }
    
    @objc func showProjectSettingView() {
        if (!isLogin) {
            self.view.showToast(toastMessage: "로그인된 정보가 없습니다.", duration: 1.5)
            return
        }
        performSegue(withIdentifier: "segueProjectList", sender: nil)
    }
    
    // ---------------------------------------------------------------------
    // 하나하나 건너 뛸 것인지 라벨링을 하지 않은 이미지로 건너 뛸 것인지 결정하는 스위치
    // ---------------------------------------------------------------------
    @objc func explorerSwitchStateDidChange(_ sender:UISwitch){
        if (sender.isOn == true){
            print("UISwitch state is now ON")
            // 모든 이미지 네비게이션 버튼 활성화
            setExploreButtonsOnOff(onOff: true)
        }
        else{
            print("UISwitch state is now Off")
        }
    }

    // ---------------------------------------------------------------------
    // 이미지 목록 갱신
    // ---------------------------------------------------------------------
    @objc func reloadImageList(_ sender: UIButton) {

        if (!isWorking) { return }
        
        // ------------------------------------------------
        // 스피너 시작
        // ------------------------------------------------
        let child = SpinnerViewController()
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        DoEvents(f: 0.05)
        
        clearLabelImage()
        loadData()

        // ------------------------------------------------
        // 스피너 종료
        // ------------------------------------------------
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }

    var viewWillAppearCount = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewWillAppearCount = viewWillAppearCount + 1
        print("---------------------------------------------------------- viewWillAppearCount = ", viewWillAppearCount)

        if (displayMenuView) {
            if (isLogin && isWorking) {
            }
            else {
                didTapMenu(menuButton)
                displayMenuView = false
            }
        }

        checkHiddenView()
        
    }
    
    var viewDidAppearCount = 0

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewDidAppearCount = viewDidAppearCount + 1
        print("---------------------------------------------------------- viewDidAppearCount = ", viewDidAppearCount)
        
        // ------------------------------------------------
        // 스피너 시작
        // ------------------------------------------------
        let child = SpinnerViewController()
        child.view.frame = self.view.frame
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
        
        if (FirstDidBecomeActive) {
            checkLoginOutInfo(newLogin: isLogin)
            FirstDidBecomeActive = false
        }
        
        if (isFromLoginMenu) {
            print("---------------------------------------------------------- isFromLoginMenu")
            if (isNewLogined) {
                LabelList.arrayLabelInfo.removeAll()
                initLabelingSettingItem()
            }
            checkLoginOutInfo(newLogin: isNewLogined)
            isFromLoginMenu = false
        }
        else if (isFromProjectMenu) {
            print("---------------------------------------------------------- isFromProjectMenu")
            if (isNewProjectBegan) {
                LabelList.arrayLabelInfo.removeAll()
                initLabelingSettingItem()
            }
            checkWorkingProjectInfo(newProject: isNewProjectBegan)
            isFromProjectMenu = false
        }
        else if (isFromSettingMenu) {
            print("---------------------------------------------------------- isFromSettingMenu")
            if (IsSettingValueChanged) {
                // 세팅화면에서 돌아오면 탐색 버튼 true 20190606
                //LabelList.arrayLabelInfo.removeAll()
                setExploreButtonsOnOff(onOff: true)
                setLabelingSettingItem()
                if (IsReviewMode) {
                    //arrowLastClick(lastButton)
                    fastSearchView.isHidden = true
                    getImageId("C")
                }
                else {
                    //arrowRightClick(rightButton)
                    fastSearchView.isHidden = false
                    getImageId("C")
                }
                IsSettingValueChanged = false
            }
            isFromSettingMenu = false
        }
        
        // ------------------------------------------------
        // 스피너 종료
        // ------------------------------------------------
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableViewLabelLeft.reloadData()
        tableViewLabelRight.reloadData()
        scrollImageWHRatio = Float(ScrollImage.frame.width / ScrollImage.frame.height)
        print("ScrollImage ratio : ", scrollImageWHRatio!)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (EditingImage.image != nil && imageRealViewRatio != nil) {
            imageViewSizeLabel.text = String(format: "폭:%5.1f,높이:%5.1f,스케일:%5.1f%%",
                                             EditingImage.image!.size.width,
                                             EditingImage.image!.size.height,
                                             imageRealViewRatio! * 100
            )
        }
    }

    func setHiddenView(view: UIView) {
        view.frame = self.view.frame
        view.backgroundColor = UIColor.white
        view.alpha = 0.35
        view.isHidden = true
        self.view.addSubview(view)
    }
    
    // --------------------------------------------------------------------------
    // 화면 상의 버튼 등 오브젝트 등의 속성 초기화
    // --------------------------------------------------------------------------
    func setProgressValue() {
        
        if (ImageList.count == 0 || total_count == 0) {
            progress.progress = 0
            progressLabel.text = "0%(0/0)"
            return
        }

        // 이미지 랜덤 가져오는 부분에서 전체수와 완료를 가져와서 해당 변수에 저장한 것을 사용
        let value = Float(complete_count) / Float(total_count)
        progress.progress = value
        progressLabel.text = String(format: "%4.1f%%(%d%/%d)", value * 100, complete_count, total_count)
        if (complete_count == total_count) {
            progressLabel.textColor = UIColor.red
        }
        else {
            progressLabel.textColor = UIColor.black
        }

//        let doneCount = LabelingDoneCount()
//        let value = Float(doneCount) / Float(ImageList.count)
//        progress.progress = value
//        progressLabel.text = String(format: "%4.1f%%(%d%/%d)", value * 100, doneCount, ImageList.count)
//        if (doneCount == ImageList.count) {
//            progressLabel.textColor = UIColor.red
//        }
//        else {
//            progressLabel.textColor = UIColor.black
//        }
    }

    func initObjectsInView() {
        
        // 화면 상단 개인 정보 등 히든 처리
        topInfoView.isHidden = true

        // 화면 하단 편집 모드 상태 및 마크 위치 정보 등 히든 처리
        bottomEditMarkInfoView.isHidden = true

        // 하단 네비게이션 툴바 히든 처리
        self.navigationController?.toolbar.isHidden = true
        
        // 진행률 오브젝트
        progress.transform = CGAffineTransform(scaleX: 1, y: 5)
        //progress.layer.cornerRadius = progress.frame.height / 4
        progress.clipsToBounds = true
        setProgressValue()

        // 상단 라벨링 작업 여부 원형으로 표시
        isDoneImage.setRounded()
        isMarkEnabledImage.setRounded()
        
        resetButton.isEnabled = false
        undoButton.isEnabled = false
        redoButton.isEnabled = false
        trashButton.isEnabled = false
        
        resetButton.isHidden = true
        undoButton.isHidden = true
        redoButton.isHidden = true
        trashButton.isHidden = true
        
        saveButton.isEnabled = false
        
        // 하단 버튼 모양 변경(둥글게)
        buttonRadius(resetButton)
        buttonRadius(undoButton)
        buttonRadius(redoButton)
        buttonRadius(trashButton)
        buttonRadius(reloadButton)

        buttonRadius(leftFastButton)
        buttonRadius(rightFastButton)
        buttonRadius(firstFastButton)
        buttonRadius(lastFastButton)
        buttonRadius(firstButton)
        buttonRadius(leftButton)
        buttonRadius(rightButton)
        buttonRadius(lastButton)
        buttonRadius(saveButton)
        
        
        // 하단 편집모드/일반모드용 이미지 원형으로 표시
        editModeImage.setRounded()
        
        // 화살표 버튼 활성화 여부 결정
        checkShowArrowButton()
    }
    
    // --------------------------------------------------------------------------
    // 버튼 코너 둥글게
    // --------------------------------------------------------------------------
    func buttonRadius(_ button: UIButton) {
        button.layer.backgroundColor = UIColor.init(red: 232/255.0, green: 232/255.0, blue: 232/255.0, alpha: 1.0).cgColor
        button.layer.cornerRadius = 10;
        button.clipsToBounds = true;
    }
    
    // --------------------------------------------------------------------------
    // 라벨링 작업과 관련된 오브젝트 리셋(이미지가 변경될 때)
    // --------------------------------------------------------------------------
    func resetObjectsRelatedToLabeling() {
        // 라벨 관련
        selectedLabelLeftIndex = -1
        selectedLabelRightIndex = -1
        tableViewLabelLeft.reloadData()
        tableViewLabelRight.reloadData()
        
        // 버튼 관련
        saveButton.isEnabled = false
    }
    
    func resetObjectsRelatedToMark() {
        // mark 및 이미지 관련
        arrayMarkShapeLayer.removeAll()
        EditingImage.layer.sublayers?.removeAll()
        clearRedoStack()
        clearUndoStack()
    }
    
    // --------------------------------------------------------------------------
    // 라벨 목록을 보여주는 좌.우 테이블뷰의 속성 초기화
    // --------------------------------------------------------------------------
    func initTableViewProperty() {
        // tableView delegate, datasource 설정
        tableViewLabelLeft.delegate = self
        tableViewLabelLeft.dataSource = self
        tableViewLabelLeft.tag = 0
        // tableView 2개를 사용하기 위하여 등록해야 함
        tableViewLabelLeft.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCellLeft")
        
        tableViewLabelRight.delegate = self
        tableViewLabelRight.dataSource = self
        tableViewLabelRight.tag = 1
        // tableView 2개를 사용하기 위하여 등록해야 함
        tableViewLabelRight.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCellRight")
        //tableViewLabelLeft.rowHeight = UITableViewAutomaticDimension
    }
    
    
    // --------------------------------------------------------------------------
    // 메인 이미지뷰 속성 설정 및 초기 이미지 설정
    // --------------------------------------------------------------------------
    func initImageViewProperty() {
        EditingImage.isUserInteractionEnabled = true
        EditingImage.clipsToBounds = true
        EditingImage.backgroundColor = UIColor.darkGray

        // 초기 이미지 설정
        EditingImage.image = #imageLiteral(resourceName: "건양대학교병원 야경")
        EditingImage.contentMode = .scaleToFill
    }
    
    // ------------------------------------------------------------------------------
    // 로그인/아웃시 이벤트 받아서 처리하는 함수
    // ------------------------------------------------------------------------------
    @objc func whenLoginOut() {
        if (isLogin) {
            signedUserNameLabel.text = LoginName
        }
        else {
            signedUserNameLabel.text = "not logged in"
        }
        clearLabelImage()
        
        // 프로그램 실행 후 UserDefault 값을 읽은 최종 상태가 로그인 상태가 아니면 로그인 창을 띄워 준다.
        // FirstDidBecomeActive 값은 AppDelegate에서 변경한다.
        if (FirstDidBecomeActive && !isLogin) {
            performSegue(withIdentifier: "segueLoginOut", sender: self)
            //PostNoti(noti: EnumMyNoti.MenuLoginTapped)
        }
    }
    
    // ------------------------------------------------------------------------------
    // 프로젝트 및 차수 선택 후 라벨링 시작 및 종료시 이벤트 받아서 처리하는 함수
    // ------------------------------------------------------------------------------
    @objc func whenLabelingBeginEnd() {
        clearLabelImage()
        if (isWorking) {
            loadData()
        }
        
        // 프로그램 실행 후 UserDefault 값을 읽은 최종 상태가 로그인 상태이고 라벨링 중인 프로젝트가 없으면 프로젝트 목록 창을 띄워 준다.
        // FirstDidBecomeActive 값은 AppDelegate에서 변경한다.
        if (FirstDidBecomeActive && isLogin && !isWorking) {
            //performSegue(withIdentifier: "segueProjectList", sender: self)
            transitionToNewContent(MenuType.projectList)
            //PostNoti(noti: EnumMyNoti.MenuProjectSettingTapped)
        }
        
    }
    

    // ------------------------------------------------------------------------------
    // 로그인/아웃시 체크(최초 로딩시에도 수행)
    // ------------------------------------------------------------------------------
    @objc func checkLoginOutInfo(newLogin new_login:Bool) {
        
        if (new_login) {
            signedUserNameLabel.text = LoginName
            clearLabelImage()
            // 라벨링 중인 작업이 있으면 Loading
            if (isWorking) {
                loadData()
            }
            // 라벨링 작업중인 것이 없으면 프로젝트 목록 화면으로 이동
            else {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    self.performSegue(withIdentifier: "segueProjectList", sender: nil)
//                }
                DispatchQueue.main.async() {
                    self.performSegue(withIdentifier: "segueProjectList", sender: nil)
                }
            }
        }
        else {
            if (!isLogin) {
                signedUserNameLabel.text = "not logged in"
                clearLabelImage()
                // 맨처음 로딩 했을 경우에만 체크하여 로그인 페이지로 이동
                if (FirstDidBecomeActive) {
                    DispatchQueue.main.async() {
                        self.performSegue(withIdentifier: "segueLoginOut", sender: nil)
                    }
                }
            }
        }
        
    }
    
    // ------------------------------------------------------------------------------
    // 프로젝트 및 차수 선택 후 라벨링 시작 및 종료시 체크
    // ------------------------------------------------------------------------------
    @objc func checkWorkingProjectInfo(newProject new_project:Bool) {
        if (new_project) {
            clearLabelImage()
            if (isWorking) {
                loadData()
            }
        }
        else {
            if (!isWorking) {
                clearLabelImage()
            }
        }
    }
    
    func loadData() {
        if (isWorking) {
            projectNameLabel.text = WorkingProjectName
            labelingOrderLabel.text = String(format: "%d", WorkingLabelingOrder)

            // drop 스위치 히든 여부 체크, 1차만 보이게 함
            //dropSwitchView.isHidden = (WorkingLabelingOrder == 1) ? false : true
            dropSwitchView.isHidden = true

            // 라벨 목록과 이미지 목록을 새롭게 가져와야 함

            // 라벨 가져오는 것 막음
//            if(loadLabelMaster()) {
//                loadImageList()
//                // 목록을 가져온 후 화살표 버튼 활성 여부 체크
//                //setProgressValue()
//                // 목록을 가져온 후 화살표 버튼 활성 여부 체크
//                checkShowArrowButton()
//            }
            loadImageList()
            // 목록을 가져온 후 화살표 버튼 활성 여부 체크
            //setProgressValue()
            // 목록을 가져온 후 화살표 버튼 활성 여부 체크
            checkShowArrowButton()
        }
    }

    func clearLabelImage() {
        // project Info
        projectNameLabel.text = "________________________"
        labelingOrderLabel.text = "__"

        // 전역 변수 목록
        //LabelList.arrayLabelInfo.removeAll()
        ImageList.removeAll()

        // 이미지, Mark
        //EditingImage.image = #imageLiteral(resourceName: "건양대학교병원 야경")
        //EditingImage.contentMode = .scaleToFill
        
        isDoneImage.backgroundColor = UIColor.yellow
        imageIDLabel.text = "____________"
        imageFileNameLabel.text = "_____________"
        imageSeqLabel.text = "______"
        piNameLabel.text = "______"
        piAgeLabel.text = "___"
        piSexLabel.text = "__"
        setProgressValue()

        // 2019년 1월 30일 막음. 서버에서 하나씩 랜덤하게 하나를 가져오므로 버튼 의미 없음
        // User Interface
//        rightButton.isEnabled = false
//        lastButton.isEnabled = false

        // 내부 변수
        resetObjectsRelatedToMark()
        resetObjectsRelatedToLabeling()
        
    }
    
    // ------------------------------------------------------------------------------
    // 해당 프로젝트에 해당하는 라벨 목록 로드
    // ------------------------------------------------------------------------------
    func loadLabelMaster() -> Bool {
        
        var success  = true
        
        LabelList.arrayLabelInfo.removeAll()
        
        if (selectLabelList()) {
            if (LabelList.arrayLabelInfo.count == 0) {
                //self.view.showToast(toastMessage: "프로젝트에 해당하는 라벨이 없습니다.", duration: 1.1)
                success = false
            }
            tableViewLabelLeft.reloadData()
            tableViewLabelRight.reloadData()
        }
        else {
            //self.view.showToast(toastMessage: "에러 메세지\r\n\r\n\(LastURLErrorMessage)\r\n", duration: 1.5)
            if (LastURLErrorMessage != "") {
                let alertProgressNoAction = UIAlertController(title: "메시지 확인", message: "\n\n\(LastURLErrorMessage)\n\n", preferredStyle: .alert)
                let otherAction = UIAlertAction(title: "확인", style: .default, handler: { action in
                    //self.dismiss(animated: true, completion: nil)
                    alertProgressNoAction.dismiss(animated: true, completion: nil)
                })
                alertProgressNoAction.addAction(otherAction)
                self.present(alertProgressNoAction, animated: false, completion: nil)
            }
            success = false
        }
        
        return success
    }
    
    // ------------------------------------------------------------------------------
    // 해당 프로젝트에 해당하는 이미지 목록 로드
    // ------------------------------------------------------------------------------
    var currentImageIndex = -1
    
    func loadImageList() {

        resetObjectsRelatedToLabeling()
        resetObjectsRelatedToMark()
        currentImageIndex = -1
        
        let temp = isTotalExplore
        
        //isTotalExploreSwitch.setOn(true, animated: false)

        FPNLFlag = "C"
        
        setExploreButtons(enable: false)
        
        if (selectImageOne()) {
            tableViewLabelLeft.reloadData()
            tableViewLabelRight.reloadData()
            setProgressValue()
            
            if (ImageList.count == 0) {
                self.view.showToast(toastMessage: "프로젝트에 해당하는 이미지가 없습니다.", duration: 1.5)
            }
            else {
                currentImageIndex = WorkingImageIndex       // 이미지 인덱스를 최종 것으로 지정
                getImageFromURL(index: currentImageIndex)   // 이미지를 가져옴
            }
        }
        else {
            //self.view.showToast(toastMessage: "에러 메세지\r\n\r\n\(LastURLErrorMessage)\r\n", duration: 1.5)
            if (LastURLErrorMessage != "") {
                let alertProgressNoAction = UIAlertController(title: "메시지 확인", message: "\n\(LastURLErrorMessage)\n\n", preferredStyle: .alert)
                let otherAction = UIAlertAction(title: "확인", style: .default, handler: { action in
                    //self.dismiss(animated: true, completion: nil)
                    if (ResponseErrorCode == -90005 && LabelList.arrayLabelInfo.count == 0) {
                        self.getLabelMasterWithResult()
                    }
                    alertProgressNoAction.dismiss(animated: true, completion: nil)
                })
                alertProgressNoAction.addAction(otherAction)
                self.present(alertProgressNoAction, animated: false, completion: nil)
            }
        }
        checkHiddenView()

        isTotalExplore = temp
        if (isTotalExplore) { setExploreButtonsOnOff(onOff: true) }

        setExploreButtons(enable: true)
        
    }
    
    // ------------------------------------------------------------------------------
    // 메인 이미지뷰에 보여줄 실제 이미지 파일을 서버로부터 가져와서 설정
    // ------------------------------------------------------------------------------
    var realImage:UIImage?
    var realImageWHRatio:Float?         // 실제이미지의 높이 대비 폭 비율
    var scrollImageWHRatio:Float?       // 스크롤 영역의 높이 대비 폭 비율
    var imageRealViewRatio:Float?       // 이미지뷰와 실제이미지의 비율(실제 이미지뷰 높이(폭) 대비 이미지뷰의 높이(폭)
    var existImage = false

    func showNotRegisterdMessage() {
        self.view.showToast(toastMessage: "\n" + imageFileNameLabel.text! + "\n\n서버에 이미지가 등록되지 않았습니다.\n", duration: 1.5)
    }

    // ------------------------------------------------------------------------------
    // 해당하는 인덱스(이미지 순서)에 해당하는 이미지를 서버로부터 로딩
    // ------------------------------------------------------------------------------
    func getImageFromURL(index:Int) {
        
        initImageZoomScale()
        existImage = false
        
//        // ------------------------------------------------
//        // 스피너 시작
//        // ------------------------------------------------
//        let child = SpinnerViewController()
//        child.view.frame = view.frame
//        view.addSubview(child.view)
//        child.didMove(toParentViewController: self)
//        DoEvents(f: 0.05)
        
        let imageId = ImageList[index].id
        imageIDLabel.text = ImageList[index].id

        let file_name = ImageList[index].serverLocation

        let encoded = file_name!.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let url = URL(string: "\(ILA4ML_URL_GETIMAGE)?file_name=\(encoded!)")
        if let data = try? Data(contentsOf: url!) {
            existImage = true
            realImage = UIImage(data: data)
            imageFileNameLabel.text = file_name
            imageFileNameLabel.textColor = UIColor.black
            imageFileNameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.thin)
        }
        else {
            existImage = false
            realImage = #imageLiteral(resourceName: "ImageNotRegistered")  // 디폴트 이미지 세팅
            
            // 이미지가 등록이 안되어 있을 경우 미등록 표시 및 메시지 출력
            imageFileNameLabel.text = String(format: "%@(미등록)", file_name!)
            imageFileNameLabel.textColor = UIColor.red
            imageFileNameLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
            showNotRegisterdMessage()
        }
        
        realImageWHRatio = Float(realImage!.size.width / realImage!.size.height)
        print("Image real size : ", realImage!.size.width, ",", realImage!.size.height, ",", realImageWHRatio!)
        EditingImage.image = realImage
        EditingImage.contentMode = .scaleAspectFit

        print("EditingImage.imageOrigin:", EditingImage.imageOrigin())
        print("EditingImage.frame:", EditingImage.frame)
        
        if (realImageWHRatio!.isLess(than: scrollImageWHRatio!)) {
            let newHeight = Float(ScrollImage.frame.height)
            imageRealViewRatio = newHeight / Float(realImage!.size.height)
        }
        else {
            let newWidth = Float(ScrollImage.frame.width)
            imageRealViewRatio = newWidth / Float(realImage!.size.width)
        }

        checkHiddenView()
        
        // 이미지 관련 정보 갱신
        if let isDone = ImageList[index].isLabelingDone  {
            isDoneImage.backgroundColor = isDone ? UIColor.green : UIColor.yellow
        }
        else {
            isDoneImage.backgroundColor = UIColor.yellow
        }
        imageSeqLabel.text = String(format: "%d/%d", index + 1, ImageList.count)
        piAgeLabel.text = String(format: "%3.0f", ImageList[index].age!)
        piNameLabel.text = String(format: "%@", ImageList[index].name!)
        piSexLabel.text = String(format: "%@", ImageList[index].sex!)
        
        isDropSwitch.isOn = ImageList[index].isDrop! == "Y" ? true : false
        self.tableViewLabelLeft.allowsSelection = !isDropSwitch.isOn
        self.tableViewLabelRight.allowsSelection = !isDropSwitch.isOn

        // 이미지 변경되었을때 관련된 오브젝트 리셋
        resetObjectsRelatedToLabeling()
        resetObjectsRelatedToMark()
        
        // 라벨링 및 마킹 정보 Load
        if (existImage) {
            // 불러들인 이미지의 라벨링,마크 결과를 읽어서 화면에 표시
            loadLabelingResult(index)
            loadMarkResult(index)
        }

        // 유저디폴트에 저장
        UserDefaults.standard.set(index, forKey: DefaultKey_ImageIndex)
        WorkingImageIndex = index
        
        if (IsReviewMode) {
            WorkingImageIdOnReviewMode = imageId!
        }
        else {
            // 마지막 로딩했던 이미지를 저장
            UserDefaults.standard.set(imageId, forKey: DefaultKey_ImageId)
            WorkingImageId = imageId!
        }
        

        print("Loaded image index : ", index)
//        // ------------------------------------------------
//        // 스피너 종료
//        // ------------------------------------------------
//        child.willMove(toParentViewController: nil)
//        child.view.removeFromSuperview()
//        child.removeFromParentViewController()
        
        saveUndoRedoButtonEnabledStatus()
    }
    
    // -----------------------------------------------------------------------------
    // edit mode toggle process variables
    // -----------------------------------------------------------------------------
    enum EditModeExitType {
        case Manual
        case Auto
    }
    
    var isEditMode = false
    var editModeExitType = EditModeExitType.Manual
    //var editModeShapeLayer = CAShapeLayer()
    var editModeMarkShape = MarkShape()
    var editModeMarkShapeID = -1
    
    // -----------------------------------------------------------------------------
    // 편집 모드 진입 및 해제 처리
    // -----------------------------------------------------------------------------
    func enterEditMode(markShape: MarkShape) {
        if (isEditMode) {
            exitEditMode()
        }
        editModeMarkShape = markShape
        isEditMode = true
        
        editModeMarkShapeID = editModeMarkShape.id!
        
        addControlPointForEllipse(layer: markShape.layer!)
        
        editModeLabel.text = String(format: "편집모드:%d", editModeMarkShapeID)
        editModeImage.backgroundColor = UIColor.blue
        trashButton.isEnabled = true
    }
    
    func exitEditMode(exitType: EditModeExitType = EditModeExitType.Auto) {
        editModeMarkShape.layer?.sublayers?.removeAll()
        controlPoints.removeAll()
        isEditMode = false
        editModeLabel.text = "일반모드"
        editModeImage.backgroundColor = UIColor.orange
        trashButton.isEnabled = false
        editModeExitType = exitType
    }
    // -----------------------------------------------------------------------------

    var isExistSelectedMark = false                     // 선택된 mark가 있는지
    var selectedMark = MarkShape()                      // 선택된 MarkShape

    var controlPoints: Array<CAShapeLayer> = Array()    // control point용 배열
    var outlineLayer = CAShapeLayer()                   // mark의 frame에 매칭되는 shape layer
    var isExistSelectedControlPoint = false             // 선택된 control point가 있는지
    var selectedControlPoint = CAShapeLayer()           // 선택된 control point
    var selectedControlPointPosition = -1               // 선택된 control point의 번호.타원의 경우 0..3, 다각형의 경우 0..n-1

    var lastScale:CGFloat!
    

    //--------------------------------------------------------------------------------
    // Main View Touch Process
    //--------------------------------------------------------------------------------
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        //guard let touch = touches.first else { return }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesMoved")
        //guard let touch = touches.first else { return }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
        //guard let touch = touches.first else { return }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled")
        //guard let touch = touches.first else { return }
    }
    */
    
    // mark 배열에 추가하고 이미지에도 추가
    func addMarkShape(markShape: MarkShape, addType: AddType = AddType.Real) {
        
        //print("addMarkShape:", markShape.shape!)
        
        arrayMarkShapeLayer.append(markShape)
        self.EditingImage.layer.addSublayer(markShape.layer!)
        
        // edit mode였던 mark일경우
        if (addType == AddType.Undo || addType == AddType.Redo || addType == AddType.Ended) {
            if (isEditMode && markShape.id == editModeMarkShapeID) {
                enterEditMode(markShape: markShape)
            }
            if (!isEditMode && editModeExitType == EditModeExitType.Auto) {
                
            }
        }
        
        if (!isEditMode && arrayMarkShapeLayer.count == 0 && editModeExitType == EditModeExitType.Auto) {
            enterEditMode(markShape: markShape)
        }
        
        printMarkShape()
        printSubLayers()
        
        if (addType == AddType.Real || addType == AddType.Redo) {
            pushUndoStack(markShape: markShape, action: UndoRedoAction.Add)
        }
        else if (addType == AddType.Ended) {
            pushUndoStack(markShape: markShape, action: UndoRedoAction.ChangeEnded)
        }
    }
    
    func addMarkEllipse(shapeLayer: CAShapeLayer, rect: CGRect) {
        
        //print("added rect:", rect)
        
        if (self.EditingImage.layer.sublayersCount() == 0) {
            markShapeId = 0
        }
        let markShape = MarkShape(shapeLayer: shapeLayer)

        markShapeId += 1

        markShape.id = markShapeId
        markShape.type = MarkType.Ellipse
        markShape.shape = rect
        
        clearRedoStack()
        
        addMarkShape(markShape: markShape, addType: AddType.Real)
    }
    
    func addMarkPolygon(shapeLayer: CAShapeLayer, points: [CGPoint]) {
        
        let markShape = MarkShape(shapeLayer: shapeLayer)
        
        markShapeId += 1
        
        markShape.id = markShapeId
        markShape.type = MarkType.Polygon
        markShape.shape = points
        
        clearRedoStack()
        
        addMarkShape(markShape: markShape, addType: AddType.Real)
    }
    
    // mark 배열에서 삭제하고 이미지에서도 삭제
    func removeMarkShape(id: Int, removeType: RemoveType = RemoveType.Real) {
        
        var deleteIndex = -1
        var deleteMarkShape = MarkShape()
        for (index, markShape) in arrayMarkShapeLayer.enumerated() {
            if (markShape.id == id) {
                deleteMarkShape = markShape
                deleteIndex = index
                break
            }
        }
        if (deleteIndex < 0) { return }
        
        if (removeType == RemoveType.Real || removeType == RemoveType.Redo) {
            pushUndoStack(markShape: deleteMarkShape, action: UndoRedoAction.Remove)
        }
        else if (removeType == RemoveType.Began) {
            pushUndoStack(markShape: deleteMarkShape, action: UndoRedoAction.ChangeBegan)
        }
        
        arrayMarkShapeLayer.remove(at: deleteIndex)
        deleteMarkShape.layer?.removeFromSuperlayer()
        
        if (isEditMode && arrayMarkShapeLayer.count == 0) {
            exitEditMode()
        }
        
        printMarkShape()
        printSubLayers()
        
    }
    
    func removeMarkShape(markShape: MarkShape, removeType: RemoveType = RemoveType.Real) {
        if let id = markShape.id {
            removeMarkShape(id: id, removeType: removeType)
        }
    }
    
    func printSubLayers() {
        return
//        if let sublayers = self.EditingImage.layer.sublayers {
//            print("sublayers:count=", sublayers.count)
//            for (index, item) in sublayers.enumerated() {
//                print("sublayers:", index, ",", item.frame.origin.x, ",", item.frame.origin.y)
//            }
//        }
    }
    
    func printMarkShape() {
        return
//        print("arrayMarkShapeLayer:count=", arrayMarkShapeLayer.count)
//        for (index, item) in arrayMarkShapeLayer.enumerated() {
//            print("arrayMarkShapeLayer:", index, ",", item.id!)
//        }
    }
    
    func disableAnimation(_ closure:()->Void){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        closure()
        CATransaction.commit()
    }
    
    
    func markAdjustBegan(markShape: MarkShape) {
        clearRedoStack()
        pushUndoStack(markShape: markShape, action: UndoRedoAction.ChangeBegan)
    }
    
    func findMarkShape(shapeLayer: CAShapeLayer) -> MarkShape? {
        for markshape in arrayMarkShapeLayer {
            if (markshape.layer == shapeLayer) {
                return markshape
            }
        }
        return nil
    }
    
    func markAdjustEnded(markShape: MarkShape) {
        pushUndoStack(markShape: markShape, action: UndoRedoAction.ChangeEnded)
//        if let markShape = findMarkShape(shapeLayer: shapeLayer) {
//            pushUndoStack(markShape: markShape, action: UndoRedoAction.ChangeEnded)
//        }
    }

    // ------------------------------------------------------------------------------
    // 마크 이동, 컨트롤포인트 조절 등 이전 위치 체크에 사용
    // ------------------------------------------------------------------------------
    var panPrevPoint = CGPoint(x:0,y:0)

    // IBAction Process
    @IBAction func undoMark(_ sender: Any) {
        popUndoStack()
    }

    @IBAction func RedoMark(_ sender: Any) {
        popRedoStack()
    }
    
    func checkHiddenView() {
        if (ImageList.count == 0) {
            hiddenView.isHidden = false
        }
        else {
            hiddenView.isHidden = true
        }
    }
    
    @IBAction func dropSwitchTriggered(_ sender: UISwitch) {
        var questionMessage = "DROP 하시겠습니까?"
        if (!sender.isOn) {
            questionMessage = "DROP 해제 하시겠습니까?"
        }

        let dialogMessage = UIAlertController(title: "확인", message: questionMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title: "예", style: .destructive, handler: { (action) -> Void in
            // ------------------------------------------------
            // 스피너 시작
            // ------------------------------------------------
            let child = SpinnerViewController()
            child.view.frame = self.view.frame
            self.view.addSubview(child.view)
            child.didMove(toParent: self)
            
            if (self.saveDropResult()) {
                print("Drop/Cancel Process OK")
                
                // 마지막에 저장했던 이미지를 유저디폴트에 저장
                let imageId = ImageList[self.currentImageIndex].id!
                UserDefaults.standard.set(imageId, forKey: DefaultKey_LastLabelingImageId)
                LastLabelingImageId = imageId
                

                if (sender.isOn) {
                    self.arrowRightClick()
                }
                else {
                }
                self.tableViewLabelLeft.allowsSelection = !sender.isOn
                self.tableViewLabelRight.allowsSelection = !sender.isOn
                self.setProgressValue()
            }
            else {
                print("Drop/Cancel Process Error")
                sender.setOn(!sender.isOn, animated: false)
                
                if (LastURLErrorMessage != "") {
                    let alertProgressNoAction = UIAlertController(title: "메시지 확인", message: "\n\(LastURLErrorMessage)\n\n", preferredStyle: .alert)
                    let otherAction = UIAlertAction(title: "확인", style: .default, handler: { action in
                        //self.dismiss(animated: true, completion: nil)
                        alertProgressNoAction.dismiss(animated: true, completion: nil)
                    })
                    alertProgressNoAction.addAction(otherAction)
                    self.present(alertProgressNoAction, animated: false, completion: nil)
                }
            }
            // ------------------------------------------------
            // 스피너 종료
            // ------------------------------------------------
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()

        })
        let cancel = UIAlertAction(title: "아니오", style: .cancel) { (action) -> Void in
            sender.setOn(!sender.isOn, animated: false)
        }
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    
    @IBAction func saveMark(_ sender: Any) {
        
        if (!existImage) {
            showNotRegisterdMessage()
            return
        }
        
        // ------------------------------------------------
        // 스피너 시작
        // ------------------------------------------------
        let child = SpinnerViewController()
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        setResult()
        if (saveLabelingResult()) {
            
            setProgressValue()
            
            isDoneImage.backgroundColor = UIColor.green
            
            let imageId = ImageList[currentImageIndex].id!
            
//            let doneCount = LabelingDoneCount()
//            if (doneCount == ImageList.count) {
//                let dialogMessage = UIAlertController(title: "확인", message: "모든 이미지 라벨링을 완료하였습니다.", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "확인", style: .default, handler: { (action) -> Void in
//                })
//                dialogMessage.addAction(ok)
//                self.present(dialogMessage, animated: true, completion: nil)
//            }
//            else {
                // 저장이 성공하면 다음 이미지로 전환

            // 마지막에 저장했던 이미지를 유저디폴트에 저장
            UserDefaults.standard.set(imageId, forKey: DefaultKey_LastLabelingImageId)
            LastLabelingImageId = imageId
            
                arrowRightClick()
//            }

            //self.view.showToast(toastMessage: "저장 완료", duration: 0.3)
        }
        else {
            //self.view.showToast(toastMessage: "에러 메세지\r\n\r\n\(LastURLErrorMessage)\r\n", duration: 1.5)
            if (LastURLErrorMessage != "") {
                let alertProgressNoAction = UIAlertController(title: "메시지 확인", message: "\n\(LastURLErrorMessage)\n\n", preferredStyle: .alert)
                let otherAction = UIAlertAction(title: "확인", style: .default, handler: { action in
                    //self.dismiss(animated: true, completion: nil)
                    alertProgressNoAction.dismiss(animated: true, completion: nil)
                })
                alertProgressNoAction.addAction(otherAction)
                self.present(alertProgressNoAction, animated: false, completion: nil)
            }
        }
        
        // ------------------------------------------------
        // 스피너 종료
        // ------------------------------------------------
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()

    }
    
    func setResult() {
        
        ImageList[currentImageIndex].isLabelingDone = true
        ImageList[currentImageIndex].labelingResult.removeAll()
        ImageList[currentImageIndex].markResult.removeAll()

        var labelingLocationResult = LabelingLocationResult()
        labelingLocationResult.target_cd = 0;
        labelingLocationResult.label_cd = getLastSelectedIndex(0);
        ImageList[currentImageIndex].labelingResult.append(labelingLocationResult);
        
        labelingLocationResult = LabelingLocationResult()
        labelingLocationResult.target_cd = 1;
        labelingLocationResult.label_cd = getLastSelectedIndex(1);
        ImageList[currentImageIndex].labelingResult.append(labelingLocationResult);
        
        for item in arrayMarkShapeLayer {
            let markResult = MarkResult()
            markResult.type = item.type
            markResult.shape = shapeStingFormat(item)
            ImageList[currentImageIndex].markResult.append(markResult)
        }
    }
    
    // -----------------------------------------------------------------------------
    // 저장버튼 활성화 여부 결정
    // -----------------------------------------------------------------------------
    func checkSaveButtonShow() {
        
        // 등록된 이미지가 없는 경우
        if (!existImage) {
            saveButton.isEnabled = false;
            return;
        }
        
        // 좌측 라벨 목록이 존재하면...
        if (LabelList.getLabelCount(location: 0) > 0) {
            // 좌,우측 라벨 목록이 모두 존재하면...
            if (LabelList.getLabelCount(location: 1) > 0) {
                saveButton.isEnabled = (selectedLabelLeftIndex < 0 || selectedLabelRightIndex < 0) ? false : true;
            }
                // 좌측 라벨 목록만 존재하면...
            else {
                saveButton.isEnabled = selectedLabelLeftIndex < 0 ? false : true;
            }
        }
        else {
            // 우측 라벨 목록만 존재하면...
            if (LabelList.getLabelCount(location: 1) > 0) {
                saveButton.isEnabled = selectedLabelRightIndex < 0 ? false : true;
            }
                // 좌,우측 라벨 목록이 모두 없으면...
            else {
                saveButton.isEnabled = false;
            }
        }
    }
    
    var beforeleftButtonisEnabled = true;
    var beforerightButtonisEnabled = true;
    var beforefirstButtonisEnabled = true;
    var beforelastButtonisEnabled = true;
    var beforeImageID = ""

    func setExploreButtonsOnOff(onOff:Bool) {
        leftButton.isEnabled = onOff
        rightButton.isEnabled = onOff
        firstButton.isEnabled = onOff
        lastButton.isEnabled = onOff
    }
    
    func setExploreButtons(enable:Bool) {
        
        if (fastSearch) {
            leftButton.isEnabled = true
            rightButton.isEnabled = true
            firstButton.isEnabled = true
            lastButton.isEnabled = true
            return
        }
        
        // 일단 무조건 위처럼 true로 하자.. 막 꼬였다.
        
        if (enable) {
            leftButton.isEnabled = beforeleftButtonisEnabled
            rightButton.isEnabled = beforerightButtonisEnabled
            firstButton.isEnabled = beforefirstButtonisEnabled
            lastButton.isEnabled = beforelastButtonisEnabled
        }
        else {
            beforeleftButtonisEnabled = leftButton.isEnabled
            beforerightButtonisEnabled = rightButton.isEnabled
            beforefirstButtonisEnabled = firstButton.isEnabled
            beforelastButtonisEnabled = lastButton.isEnabled

            if (currentImageIndex >= 0) {
                if (ImageList.count > 0) {
                    if let befId = ImageList[currentImageIndex].id {
                        beforeImageID = befId
                    }
                    else {
                        beforeImageID = ""
                    }
                }
                else {
                    beforeImageID = ""
                }
            }
            else {
                beforeImageID = ""
            }

            leftButton.isEnabled = enable
            rightButton.isEnabled = enable
            firstButton.isEnabled = enable
            lastButton.isEnabled = enable

        }

        if (enable && more_image != "ERROR") {
        //if (enable) {

            switch FPNLFlag {
            case "F", "P":
                if (more_image == "N" || ResponseErrorCode == -90005) {
                    leftButton.isEnabled = false
                    firstButton.isEnabled = false
                }
                if (currentImageIndex >= 0) {
                    if (beforeImageID != ImageList[currentImageIndex].id!) {
                        rightButton.isEnabled = true
                        lastButton.isEnabled = true
                    }
                }
            case "N", "L":
                if (more_image == "N" || ResponseErrorCode == -90005) {
                    rightButton.isEnabled = false
                    lastButton.isEnabled = false
                }
                if (currentImageIndex >= 0) {
                    if (beforeImageID != ImageList[currentImageIndex].id!) {
                        leftButton.isEnabled = true
                        firstButton.isEnabled = true
                    }
                }
            case "C":
                rightButton.isEnabled = true
                lastButton.isEnabled = true
                rightButton.isEnabled = true
                lastButton.isEnabled = true
            default :
                rightButton.isEnabled = true
                lastButton.isEnabled = true
                rightButton.isEnabled = true
                lastButton.isEnabled = true
                break;
            }
        }
    }
    

    // -----------------------------------------------------------------------------
    // 기존의 라벨링 결과를 좌우측 라벨링 테이블뷰에 리프레쉬하고 선택된 인덱스 변수에 대입
    // -----------------------------------------------------------------------------
    func loadLabelingResult(_ currentImageIndex:Int) {
        if (currentImageIndex < 0) { return }
        for item in ImageList[currentImageIndex].labelingResult {
            if (item.target_cd == 0) {
                //selectedLabelLeftIndex = item.label_cd!
                selectedLabelLeftIndex = LabelList.getIndexOfLabelCode(location: 0, labelCode: item.label_cd!)
            }
            else if (item.target_cd == 1) {
                //selectedLabelRightIndex = item.label_cd!
                selectedLabelRightIndex = LabelList.getIndexOfLabelCode(location: 1, labelCode: item.label_cd!)
            }
        }
        tableViewLabelLeft.reloadData()
        tableViewLabelRight.reloadData()
        checkSaveButtonShow()
    }
    
    // -----------------------------------------------------------------------------
    // 기존의 마크 결과를 이미지 상에 표시
    // -----------------------------------------------------------------------------
    func loadMarkResult(_ currentImageIndex:Int) {
        if (currentImageIndex < 0) { return }
        for item in ImageList[currentImageIndex].markResult {
            if (item.type == MarkType.Ellipse) {

                print("------------------------------------------------")
                print("item.shape:", item.shape!)
                let rectArray = item.shape!.components(separatedBy: ",")
                print("imageRealViewRatio: ", imageRealViewRatio!)
                let x = CGFloat((rectArray[0] as NSString).floatValue) * CGFloat(imageRealViewRatio!) + EditingImage.imageOrigin().x
                let y = CGFloat((rectArray[1] as NSString).floatValue) * CGFloat(imageRealViewRatio!) + EditingImage.imageOrigin().y
                let w = CGFloat((rectArray[2] as NSString).floatValue) * CGFloat(imageRealViewRatio!)
                let h = CGFloat((rectArray[3] as NSString).floatValue) * CGFloat(imageRealViewRatio!)
                
                print("rectArray.x:", x)
                print("EditingImage.imageOrigin().x:", EditingImage.imageOrigin().x)

                drawEllipse(rect: CGRect(x: x, y: y, width: w, height: h))
            }
            else if (item.type == MarkType.Polygon) {
            }
        }
    }
    
    @IBAction func trashMark(_ sender: Any) {
        // 편집중인 mark를 삭제
        if (isEditMode) {
            var deleteId = -1
            for markShape in arrayMarkShapeLayer {
                if (markShape.layer == editModeMarkShape.layer) {
                    deleteId = markShape.id!
                    break
                }
            }
            if (deleteId >= 0) {
                trashButton.isEnabled = false
                clearRedoStack()
                removeMarkShape(id: deleteId, removeType:RemoveType.Real)
            }
        }
    }

    @IBAction func resetClick(_ sender: Any) {
        resetObjectsRelatedToMark()
        if (isEditMode) {
            exitEditMode()
        }
    }

    @IBAction func arrowFirstFastClick(_ sender: Any) {
        fastSearch = true
        getImageId("F")
    }
    
    @IBAction func arrowLeftFastClick(_ sender: Any) {
        fastSearch = true
        getImageId("P")
    }
    
    @IBAction func arrowRightFastClick(_ sender: Any) {
        fastSearch = true
        getImageId("N")
    }
    
    @IBAction func arrowLastFastClick(_ sender: Any) {
        fastSearch = true
        getImageId("L")
    }
    

    @IBAction func arrowFirstClick(_ sender: Any) {
        fastSearch = false
        getImageId("F")
        if (WorkingLabelingOrder == 1) {
            leftButton.isEnabled = false
            firstButton.isEnabled = false
        }


//        if (ImageList.count == 0 || currentImageIndex == 0) { return }
//        currentImageIndex = getFirstImageIndex(isTotalExploreSwitch.isOn, currentImageIndex);
//        getImageFromURL(index: currentImageIndex)
//        checkShowArrowButton()
    }
    
    func getFirstImageIndex(_ isTotalExplore:Bool,_ currIndex:Int) -> Int {
        // 배열에 값이 없거나 첫번째 위치이면 현재값 리턴
        if (ImageList.count == 0 || currentImageIndex == 0) { return currIndex }

        // 첫번째 인덱스로 가려면..
        if (isTotalExplore) {
            return 0;
        }
        // 작업하지 않은 첫번째 이미지로 가려면..
        else {
            // 인덱스 값을 0부터 변경하면서 찾음
            for i in (0 ..< ImageList.count) {
                if let done = ImageList[i].isLabelingDone {
                    // 아직 라벨링 작업을 하지 않았으면 리턴
                    print("인덱스 값 : ", i, ", ", done);
                    if (!done) {
                        return i;
                    }
                }
            }
            return currIndex;
        }
    }
    
    @IBAction func arrowLeftClick(_ sender: Any) {

        fastSearch = false
        getImageId("P")
        
        if (WorkingLabelingOrder == 1 && ResponseErrorCode == -90005) {
            leftButton.isEnabled = false
            firstButton.isEnabled = false
        }

//        if (ImageList.count == 0 || (currentImageIndex - 1) < 0) { return }
//        //currentImageIndex = currentImageIndex - 1
//        currentImageIndex = getPreviousImageIndex(isTotalExploreSwitch.isOn, currentImageIndex);
//        getImageFromURL(index: currentImageIndex)
//        checkShowArrowButton()
    }
    
    func getPreviousImageIndex(_ isTotalExplore:Bool,_ currIndex:Int) -> Int {
        // 배열에 값이 없거나 첫번째 위치이면 현재값 리턴
        if (ImageList.count == 0 || currentImageIndex == 0) { return currIndex }

        // 이전 인덱스로 가려면..
        if (isTotalExplore) {
            return currIndex - 1;
        }
        // 작업하지 않은 첫번째 이전 이미지로 가려면..
        else {
            // 인덱스 값을 뒤에서부터 변경하면서 찾음
            for i in (0 ..< currIndex).reversed() {
                if let done = ImageList[i].isLabelingDone {
                    // 아직 라벨링 작업을 하지 않았으면 리턴
                    print("인덱스 값 : ", i, ", ", done);
                    if (!done) {
                        return i;
                    }
                }
            }
            return currIndex;
        }
    }
    
    @IBAction func reloadClick(_ sender: Any) {
        if (ImageList.count == 0) { return }
        getImageFromURL(index: currentImageIndex)
    }

    func getImageId(_ prevNextFlag:String) {
        
        setExploreButtons(enable: false)
        
        // ------------------------------------------------
        // 스피너 시작
        // ------------------------------------------------
        let child = SpinnerViewController()
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        //DoEvents(f: 0.05)
        
        FPNLFlag = prevNextFlag
        more_image = "ERROR"

        if (selectImageOne()) {
            
            tableViewLabelLeft.reloadData()
            tableViewLabelRight.reloadData()

            setProgressValue()
            
            if (ImageList.count == 0) {
                self.view.showToast(toastMessage: "프로젝트에 해당하는 이미지가 없습니다.", duration: 1.5)
            }
            else {
                currentImageIndex = 0                       // 1개씩 가져오므로 항상 0
                getImageFromURL(index: currentImageIndex)
                checkShowArrowButton()
            }
        }
        else {
            //self.view.showToast(toastMessage: "에러 메세지\r\n\r\n\(LastURLErrorMessage)\r\n", duration: 1.5)
            if (LastURLErrorMessage != "") {
                let alertProgressNoAction = UIAlertController(title: "메시지 확인", message: "\n\(LastURLErrorMessage)\n\n", preferredStyle: .alert)
                let otherAction = UIAlertAction(title: "확인", style: .default, handler: { action in
                    //self.dismiss(animated: true, completion: nil)
                    if (ResponseErrorCode == -90005 && LabelList.arrayLabelInfo.count == 0) {
                        self.getLabelMasterWithResult()
                    }
                    alertProgressNoAction.dismiss(animated: true, completion: nil)
                })
                alertProgressNoAction.addAction(otherAction)
                self.present(alertProgressNoAction, animated: false, completion: nil)
            }
        }

        setExploreButtons(enable: true)

        // ------------------------------------------------
        // 스피너 종료
        // ------------------------------------------------
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        
    }
    
    @IBAction func arrowRightClick(_ sender: Any? = nil) {

        fastSearch = false
        getImageId("N")
        if (WorkingLabelingOrder == 1 && ResponseErrorCode == -90005) {
            rightButton.isEnabled = false
            lastButton.isEnabled = false
        }

//
//        if (ImageList.count == 0 || (currentImageIndex + 1) >= ImageList.count) { return }
//        //currentImageIndex = currentImageIndex + 1
//        currentImageIndex = getNextImageIndex(isTotalExploreSwitch.isOn, currentImageIndex);
//        getImageFromURL(index: currentImageIndex)
//        checkShowArrowButton()
    }
    
    func getNextImageIndex(_ isTotalExplore:Bool,_ currIndex:Int) -> Int {
        // 배열에 값이 없거나 마지막 위치이면 현재 값 리턴
        if (ImageList.count == 0 || (currIndex + 1) >= ImageList.count) { return currIndex }
        
        print("현재 인덱스 값 : ", currIndex);
        // 다음 인덱스로 가려면..
        if (isTotalExplore) {
            return currIndex + 1;
        }
        else {
            // 작업하지 않은 이미지로 가려면..
            for i in (currIndex+1) ..< ImageList.count {
                if let done = ImageList[i].isLabelingDone {
                    // 아직 라벨링 작업을 하지 않았으면 리턴
                    print("인덱스 값 : ", i, ", ", done);
                    if (!done) {
                        return i;
                    }
                }
                else {
                    return i;
                }
            }
            return currIndex;
        }
    }
    
    @IBAction func arrowLastClick(_ sender: Any) {

        fastSearch = false
        getImageId("L")
        if (WorkingLabelingOrder == 1) {
            rightButton.isEnabled = false
            lastButton.isEnabled = false
        }

//        if (ImageList.count == 0 || currentImageIndex == (ImageList.count - 1)) { return }
//        currentImageIndex = getLastImageIndex(isTotalExploreSwitch.isOn, currentImageIndex);
//        getImageFromURL(index: currentImageIndex)
//        checkShowArrowButton()
    }
    
    func getLastImageIndex(_ isTotalExplore:Bool,_ currIndex:Int) -> Int {
        // 배열에 값이 없거나 마지막 위치이면 현재 값 리턴
        if (ImageList.count == 0 || currentImageIndex == (ImageList.count - 1)) { return currIndex }

        print("현재 인덱스 값 : ", currIndex);
        // 마지막 인덱스로 가려면..
        if (isTotalExplore) {
            return ImageList.count - 1;
        }
        else {
            // 작업하지 않은 마지막 이미지로 가려면..
            for i in (0 ..< ImageList.count).reversed() {
                if let done = ImageList[i].isLabelingDone {
                    // 아직 라벨링 작업을 하지 않았으면 리턴
                    print("인덱스 값 : ", i, ", ", done);
                    if (!done) {
                        return i;
                    }
                }
                else {
                    return i;
                }
            }
            return currIndex;
        }
    }
    
    var referImageList:[String] = []
    var referImages:[UIImage] = []
    
    func showReferImageScreen() {
        // ------------------------------------------------
        // 참조 이미지 정보 다운로드
        // ------------------------------------------------
        let alertProgressNoAction = UIAlertController(title: "참조 이미지 다운로드 중...\n\n\n", message: nil, preferredStyle: .alert)
        let spinnerIndicator = UIActivityIndicatorView(style: .whiteLarge)
        spinnerIndicator.center = CGPoint(x: 135.0, y: 85.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        alertProgressNoAction.view.addSubview(spinnerIndicator)
        self.present(alertProgressNoAction, animated: false, completion: nil)
        
        let success = getReferImageList()
        if (success) {
            
//            if (referImageList.count == 0) {
//                spinnerIndicator.removeFromSuperview()
//                let otherAction = UIAlertAction(title: "OK", style: .default, handler: { action in
//                    //self.dismiss(animated: true, completion: nil)
//                    alertProgressNoAction.dismiss(animated: true, completion: nil)
//                })
//                alertProgressNoAction.title = "메세지 확인\n\n참조 이미지가 없습니다.\n\n"
//                alertProgressNoAction.addAction(otherAction)
//                return
//            }
//            else {
                getImagesFromURL()
                alertProgressNoAction.dismiss(animated: false, completion: nil)
//            }
        }
        else {
            spinnerIndicator.removeFromSuperview()
            let otherAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                //self.dismiss(animated: true, completion: nil)
                alertProgressNoAction.dismiss(animated: true, completion: nil)
            })
            alertProgressNoAction.title = "메세지 확인\n\n\(LastURLErrorMessage)\n\n"
            alertProgressNoAction.addAction(otherAction)
            return
        }
        
        performSegue(withIdentifier: "segueReferImages", sender: nil)

    }
    
    func getImagesFromURL() {
        
        referImages.removeAll()

        for file_name in referImageList {
            let encoded = file_name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let url = URL(string: "\(ILA4ML_URL_GETIMAGE)?file_name=\(encoded!)")
            if let data = try? Data(contentsOf: url!) {
                referImages.append(UIImage(data: data)!)
            }
            else {
                print("image file name " + file_name + "download error")
            }
        }
        
        // 메인이미지부터 나중에 추가
        if let img = EditingImage.image {
            referImages.append(img)
        }
        
    }
    
    func checkShowArrowButton() {
        
        // 좌우 이동 버튼이 크게 의미가 없음.
        // 라벨링 후 다음 이미지를 무조건 랜덤하게 가져오기 때문
        
        return
        
//        if (ImageList.count == 0) {
//            firstButton.isEnabled = false
//            leftButton.isEnabled = false
//            rightButton.isEnabled = false
//            lastButton.isEnabled = false
//        }
//        else {
//            if (currentImageIndex == 0) {
//                firstButton.isEnabled = false
//                leftButton.isEnabled = false
//                rightButton.isEnabled = true
//                lastButton.isEnabled = true
//            }
//            else if(currentImageIndex == ImageList.count - 1) {
//                firstButton.isEnabled = true
//                leftButton.isEnabled = true
//                rightButton.isEnabled = false
//                lastButton.isEnabled = false
//            }
//            else {
//                firstButton.isEnabled = true
//                leftButton.isEnabled = true
//                rightButton.isEnabled = true
//                lastButton.isEnabled = true
//            }
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // -------------------------------------------------------------------------------
    // 네비게이션 BAR 블링크(blink) 처리
    // -------------------------------------------------------------------------------
    fileprivate var naviBarBlinkEndless = false
    fileprivate var naviBarBlinkRunning = false
    fileprivate var naviBarColor = UIColor.white
    
    func naviBarBlinkRunLoop() {
        
        self.naviBarBlinkRunning = true
        
        while (naviBarBlinkEndless) {
            
            if naviBarColor != UIColor.white {
                naviBarColor = UIColor.white
            }
            else {
                if (IsReviewMode) {
                    naviBarColor = UIColor.yellow
                }
                    //                else if (IncludeLabelingDoneImage) {
                    //                    naviBarColor = UIColor.green
                    //                }
                else {
                    naviBarColor = UIColor.white
                }
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    self.navigationController?.navigationBar.barTintColor = self.naviBarColor
                    self.navigationController?.navigationBar.layoutIfNeeded()
                }
            }
            
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
    
    func naviBarBlinkStart() {
        
        if (naviBarBlinkRunning) {
            print("이미 title blink 프로세스가 동작중입니다.")
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            print("title Blink Start")
            self.naviBarBlinkEndless = true
            self.naviBarBlinkRunLoop()
            DispatchQueue.main.async {
                print("title blink Stop")
                self.naviBarBlinkRunning = false
            }
        }
    }
    
    func naviBarBlinkStop() {
        if (!naviBarBlinkRunning) {
            print("이미 title blink 프로세스가 정지 상태입니다.")
            return
        }
        naviBarBlinkEndless = false
    }
    // -------------------------------------------------------------------------------

}


// Menu view 표시용
extension LabelingVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        menuTransition.isPresenting = true
        return menuTransition
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        menuTransition.isPresenting = false
        return menuTransition
    }
    
    
}
