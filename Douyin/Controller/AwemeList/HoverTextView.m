//
//  HoverTextView.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "HoverTextView.h"
#import "Constants.h"
#import "NSString+Extension.h"
#import "NSNotification+Extension.h"
#define LEFT_INSET 40
#define RIGHT_INSET 100
#define TOP_BOTTOM_INSET 15

@interface HoverTextView ()<UITextViewDelegate>
@property (nonatomic, assign) CGFloat          textHeight;
@property (nonatomic, assign) CGFloat          keyboardHeight;
@property (nonatomic, retain) UILabel          *placeHolderLabel;
@property (nonatomic, strong) UIImageView      *editImageView;
@property (nonatomic, strong) UIImageView      *atImageView;
@property (nonatomic, strong) UIImageView      *sendImageView;
@property (nonatomic, strong) UIView           *splitLine;
@end

@implementation HoverTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if(self) {
        self.backgroundColor = ColorClear;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGuesture:)]];
        
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = ColorClear;
        
        _textView.clipsToBounds = NO;
        _textView.textColor = ColorWhite;
        _textView.font = BigFont;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.scrollEnabled = NO;
        _textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        _textView.textContainerInset = UIEdgeInsetsMake(TOP_BOTTOM_INSET, LEFT_INSET, TOP_BOTTOM_INSET, RIGHT_INSET);
        _textView.textContainer.lineFragmentPadding = 0;
        _textHeight = ceilf(_textView.font.lineHeight);
        
        _placeHolderLabel = [[UILabel alloc]init];
        _placeHolderLabel.text = @"有爱评论，说点儿好听的~";
        _placeHolderLabel.textColor = ColorWhiteAlpha40;
        _placeHolderLabel.font = BigFont;
        [_textView addSubview:_placeHolderLabel];
        [_textView setValue:_placeHolderLabel forKey:@"_placeholderLabel"];
        
        _editImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
        _editImageView.contentMode = UIViewContentModeCenter;
        _editImageView.image = [UIImage imageNamed:@"ic30Pen1"];
        [_textView addSubview:_editImageView];
        
        _atImageView = [[UIImageView alloc] init];
        _atImageView.contentMode = UIViewContentModeCenter;
        _atImageView.image = [UIImage imageNamed:@"ic30WhiteAt"];
        [_textView addSubview:_atImageView];
        
        _sendImageView = [[UIImageView alloc] init];
        _sendImageView.contentMode = UIViewContentModeCenter;
        _sendImageView.image = [UIImage imageNamed:@"ic30WhiteSend"];
        _sendImageView.userInteractionEnabled = YES;
        [_sendImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSend)]];
        [_textView addSubview:_sendImageView];
        
        _splitLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5f)];
        _splitLine.backgroundColor = ColorWhiteAlpha40;
        [_textView addSubview:_splitLine];
        
        [self addSubview:_textView];
        
        _textView.delegate = self;
        //为软键盘弹出和收起动作注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = [self superview].bounds;
    [self updateViewFrameAndState];
}

- (void)updateViewFrameAndState {
    [self updateIconState];
    [self updateRightViewsFrame];
    [self updateTextViewFrame];
}

- (void)updateTextViewFrame {
    CGFloat textViewHeight = _keyboardHeight > 0 ? _textHeight + 2*TOP_BOTTOM_INSET : ceilf(_textView.font.lineHeight) + 2*TOP_BOTTOM_INSET;
    self.textView.frame = CGRectMake(0, SCREEN_HEIGHT - _keyboardHeight - textViewHeight, SCREEN_WIDTH, textViewHeight);
}

- (void)updateRightViewsFrame {
    CGFloat originX = SCREEN_WIDTH;
    originX -= _keyboardHeight > 0 ? 50 : (_textView.text.length > 0 ? 50 : 0);
    [UIView animateWithDuration:0.25 animations:^{
        self.sendImageView.frame = CGRectMake(originX, 0, 50, 50);
        self.atImageView.frame = CGRectMake(CGRectGetMinX(self.sendImageView.frame) - 50, 0, 50, 50);
    }];
}

- (void)updateIconState {
    _editImageView.image = _keyboardHeight > 0 ? [UIImage imageNamed:@"ic90Pen1"] : (_textView.text.length > 0 ? [UIImage imageNamed:@"ic90Pen1"] : [UIImage imageNamed:@"ic30Pen1"]);
    _atImageView.image = _keyboardHeight > 0 ? [UIImage imageNamed:@"ic90WhiteAt"] : (_textView.text.length > 0 ? [UIImage imageNamed:@"ic90WhiteAt"] : [UIImage imageNamed:@"ic30WhiteAt"]);
    _sendImageView.image = _textView.text.length > 0 ? [UIImage imageNamed:@"ic30RedSend"] : [UIImage imageNamed:@"ic30WhiteSend"];
}
// send text action
- (void)onSend {
    if(_delegate) {
        [_delegate onSendText:_textView.text];
        _textView.text = @"";
        _textHeight = ceilf(_textView.font.lineHeight);
        [_textView resignFirstResponder];
    }
}

//keyboard notification
- (void)keyboardWillShow:(NSNotification *)notification {
    self.backgroundColor = ColorBlackAlpha40;
    //获取当前软键盘高度
    _keyboardHeight = [notification keyBoardHeight];
    [self updateViewFrameAndState];
    if(_hoverDelegate){
        [_hoverDelegate hoverTextViewStateChange:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.backgroundColor = ColorClear;
    //软键盘高度置0
    _keyboardHeight = 0;
    [self updateViewFrameAndState];
    if(_hoverDelegate){
        [_hoverDelegate hoverTextViewStateChange:NO];
    }
}

//textView delegate
-(void)textViewDidChange:(UITextView *)textView {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
    textView.attributedText = attributedText;
    if([textView.attributedText.string isEqualToString:@""]) {
        _textHeight = ceilf(_textView.font.lineHeight);
    }else {
        _textHeight = [attributedText multiLineSize:SCREEN_WIDTH - LEFT_INSET - RIGHT_INSET].height;
    }
    [self updateViewFrameAndState];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [self onSend];
        return NO;
    }
    return YES;
}


//handle guesture tap
- (void)handleGuesture:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:_textView];
    if(![_textView.layer containsPoint:point]) {
        [_textView resignFirstResponder];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self){
        if(hitView.backgroundColor == ColorClear) {
            return nil;
        }
    }
    return hitView;
}

- (void)dealloc {
}
@end
