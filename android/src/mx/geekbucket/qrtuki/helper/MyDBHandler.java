package mx.geekbucket.qrtuki.helper;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabase.CursorFactory;
import android.database.sqlite.SQLiteOpenHelper;

public class MyDBHandler extends SQLiteOpenHelper {

	private static final int DATABASE_VERSION = 1;
	private static final String DATABASE_NAME = "tuki.db";
	public static final String TABLE_CONFIG = "config";
	
	public MyDBHandler(Context context) {
		super(context, DATABASE_NAME, null, 1);
	}
	
	@Override
	public void onCreate(SQLiteDatabase arg0) {
		// TODO Auto-generated method stub
	}

	@Override
	public void onUpgrade(SQLiteDatabase arg0, int arg1, int arg2) {
		// TODO Auto-generated method stub
	}
    
    public int updateQR(String qr) {
        SQLiteDatabase db = this.getWritableDatabase();
        
        // updating row
        System.out.println("Corona QR: "+qr);
        String strSQL = "UPDATE config SET qr = '"+ qr + "'";
        db.execSQL(strSQL);
        return 1;
    }

} 