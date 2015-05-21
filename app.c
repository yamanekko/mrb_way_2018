/**
 ******************************************************************************
 ** ファイル名 : app.c
 **
 ** 概要 : 2輪倒立振子ライントレースロボットのTOPPERS/HRP2用Cサンプルプログラム
 **
 ** 注記 : sample_c4 (sample_c3にBluetooth通信リモートスタート機能を追加)
 ** 	  C用のサンプルコードsample_c4をmrubyに移植し、Ruby向けに調整
 ******************************************************************************
 **/

#include "ev3api.h"
#include "syssvc/serial.h"	// for Bluetooth(log)
#include "app.h"

#if defined(BUILD_MODULE)
#include "module_cfg.h"
#else
#include "kernel_cfg.h"
#endif

#include "mruby.h"
#include "mruby/irep.h"
#include "mruby/string.h"


#define DEBUG

#ifdef DEBUG
#define _debug(x) (x)
#else
#define _debug(x)
#endif

/* LCDフォントサイズ */
#define CALIB_FONT (EV3_FONT_SMALL)
#define CALIB_FONT_WIDTH (6/*TODO: magic number*/)
#define CALIB_FONT_HEIGHT (8/*TODO: magic number*/)

/* void* */
/* mrb_tlsf_allocf(mrb_state *mrb, void *p, size_t size, void *ud) */
/* { */
/*   if (size == 0) { */
/*     tlsf_free(p); */
/*     return NULL; */
/*   } */
/*   else { */
/*     return tlsf_realloc(p, size); */
/*   } */
/* } */


/* メインタスク */
void main_task(intptr_t unused)
{
    /* LCD画面にログを表示 */
	ev3_lcd_fill_rect(0, 0, EV3_LCD_WIDTH, EV3_LCD_HEIGHT, EV3_LCD_WHITE);
    ev3_lcd_draw_string("EV3way-ET step 1", 0, CALIB_FONT_HEIGHT*1);

	static mrb_state *mrb = NULL;
	mrb_value ret;

	mrb = mrb_open();
	struct RClass * ev3rt = mrb_class_get(mrb, "EV3RT");

	mrb_define_const(mrb, ev3rt, "BALANCE_TASK_ID", mrb_fixnum_value(BALANCE_TASK));
	mrb_define_const(mrb, ev3rt, "WATCH_TASK_ID", mrb_fixnum_value(WATCH_TASK));
	mrb_define_const(mrb, ev3rt, "MAIN_TASK_ID", mrb_fixnum_value(MAIN_TASK));
	mrb_define_const(mrb, ev3rt, "BALANCE_CYC_ID", mrb_fixnum_value(BALANCE_CYC));
	mrb_define_const(mrb, ev3rt, "WATCH_CYC_ID", mrb_fixnum_value(WATCH_CYC));

	//mrb->code_fetch_hook = code_fetch;	//デバッグできるようになったら使う

    /* LCD画面にログを表示 */
    ev3_lcd_fill_rect(0, 0, EV3_LCD_WIDTH, EV3_LCD_HEIGHT, EV3_LCD_WHITE);
    ev3_lcd_draw_string("EV3way-ET step 2", 0, CALIB_FONT_HEIGHT*1);

    #include "app_ruby.h"

    /* LCD画面にログを表示 */
     ev3_lcd_fill_rect(0, 0, EV3_LCD_WIDTH, EV3_LCD_HEIGHT, EV3_LCD_WHITE);
     ev3_lcd_draw_string("EV3way-ET step 3", 0, CALIB_FONT_HEIGHT*1);

     ret = mrb_load_irep (mrb, bcode);
     if(mrb->exc){
		 if(!mrb_undef_p(ret)){
			 ev3_lcd_fill_rect(0, 0, EV3_LCD_WIDTH, EV3_LCD_HEIGHT, EV3_LCD_WHITE);
			 ev3_lcd_draw_string("EV3way-ET ERR", 0, CALIB_FONT_HEIGHT*1);
		     mrb_value s = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
		     if (mrb_string_p(s)) {
		       ev3_lcd_draw_string(RSTRING_PTR(s), 0, CALIB_FONT_HEIGHT*3);
		       serial_wri_dat(SIO_PORT_BT, RSTRING_PTR(s), RSTRING_LEN(s));

		     } else {
		       ev3_lcd_draw_string("error unknown", 0, CALIB_FONT_HEIGHT*3);
		     }
		 }
     }

    mrb_close(mrb);
    ext_tsk();
}

// 停止ボタン監視タスク
void cyclick_handler_status_check(intptr_t exinf) {
//	const char msg[23] = "cyc_handler wake up!\r\n";
//    serial_wri_dat(SIO_PORT_BT, (const char *)msg, 23);
	wup_tsk(WATCH_TASK);
}

void watch_task(intptr_t exinf) {
    static mrb_state *mrb = NULL;
	mrb_value ret;

	mrb = mrb_open();

	struct RClass * ev3rt = mrb_class_get(mrb, "EV3RT");

	mrb_define_const(mrb, ev3rt, "BALANCE_TASK_ID", mrb_fixnum_value(BALANCE_TASK));
	mrb_define_const(mrb, ev3rt, "WATCH_TASK_ID", mrb_fixnum_value(WATCH_TASK));
	mrb_define_const(mrb, ev3rt, "MAIN_TASK_ID", mrb_fixnum_value(MAIN_TASK));
	mrb_define_const(mrb, ev3rt, "BALANCE_CYC_ID", mrb_fixnum_value(BALANCE_CYC));
	mrb_define_const(mrb, ev3rt, "WATCH_CYC_ID", mrb_fixnum_value(WATCH_CYC));

	#include "watch_ruby.h"
    ret = mrb_load_irep (mrb, watchcode);
    if(mrb->exc){
		 if(!mrb_undef_p(ret)){
			 ev3_lcd_fill_rect(0, 0, EV3_LCD_WIDTH, EV3_LCD_HEIGHT, EV3_LCD_WHITE);
			 ev3_lcd_draw_string("EV3way-ET ERR", 0, CALIB_FONT_HEIGHT*1);
		     mrb_value s = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
		     if (mrb_string_p(s)) {
		       ev3_lcd_draw_string(RSTRING_PTR(s), 0, CALIB_FONT_HEIGHT*3);
		       serial_wri_dat(SIO_PORT_BT, RSTRING_PTR(s), RSTRING_LEN(s));

		     } else {
		       ev3_lcd_draw_string("error unknown", 0, CALIB_FONT_HEIGHT*3);
		     }
		 }
    }
    mrb_close(mrb);

}

void cyclick_handler(intptr_t exinf) {
//	const char msg[23] = "cyc_handler wake up!\r\n";
//    serial_wri_dat(SIO_PORT_BT, (const char *)msg, 23);
	wup_tsk(BALANCE_TASK);
}

// 倒立制御タスク
void cyclick_balance(intptr_t exinf) {
//	const char msg[23] = "cyc_balance wake up!\r\n";
//    serial_wri_dat(SIO_PORT_BT, (const char *)msg, 23);

    static mrb_state *mrb = NULL;
	mrb_value ret;

	mrb = mrb_open();
	struct RClass * ev3rt = mrb_class_get(mrb, "EV3RT");

	mrb_define_const(mrb, ev3rt, "BALANCE_TASK_ID", mrb_fixnum_value(BALANCE_TASK));
	mrb_define_const(mrb, ev3rt, "WATCH_TASK_ID", mrb_fixnum_value(WATCH_TASK));
	mrb_define_const(mrb, ev3rt, "MAIN_TASK_ID", mrb_fixnum_value(MAIN_TASK));
	mrb_define_const(mrb, ev3rt, "BALANCE_CYC_ID", mrb_fixnum_value(BALANCE_CYC));
	mrb_define_const(mrb, ev3rt, "WATCH_CYC_ID", mrb_fixnum_value(WATCH_CYC));

	#include "balance_ruby.h"
    ret = mrb_load_irep (mrb, cyccode);
    if(mrb->exc){
		 if(!mrb_undef_p(ret)){
			 ev3_lcd_fill_rect(0, 0, EV3_LCD_WIDTH, EV3_LCD_HEIGHT, EV3_LCD_WHITE);
			 ev3_lcd_draw_string("EV3way-ET ERR", 0, CALIB_FONT_HEIGHT*1);
		     mrb_value s = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
		     if (mrb_string_p(s)) {
		       ev3_lcd_draw_string(RSTRING_PTR(s), 0, CALIB_FONT_HEIGHT*3);
		       serial_wri_dat(SIO_PORT_BT, RSTRING_PTR(s), RSTRING_LEN(s));

		     } else {
		       ev3_lcd_draw_string("error unknown", 0, CALIB_FONT_HEIGHT*3);
		     }
		 }
    }
    mrb_close(mrb);

}

int _fini(void){
	return 0;
}
