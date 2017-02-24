package mx.geekbucket.qrtuki;

import mx.geekbucket.qrtuki.R;
import mx.geekbucket.qrtuki.helper.*;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.*;

import net.sourceforge.zbar.Config;
import net.sourceforge.zbar.Image;
import net.sourceforge.zbar.ImageScanner;
import net.sourceforge.zbar.Symbol;
import net.sourceforge.zbar.SymbolSet;
import android.media.MediaPlayer;

import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.Size;
import android.os.*;

/**
 * An example full-screen activity that shows and hides the system UI (i.e.
 * status bar and navigation/system bar) with user interaction.
 * 892 2822  25
 * 892 3395
 
 DD 500gb * - 1250
 RAM 4gb DDR4 - 850
 ASUS-H110m-e/m.22
 */
public class QRActivity extends Activity {
    private MediaPlayer mpCamera;
    private MediaPlayer mpTick;
    private Camera mCamera;
    private CameraPreview mPreview;
    private Handler autoFocusHandler;
    private boolean previewing = true;
    private MyDBHandler db;
    private CountDownTimer aCounter;
    
    static {
        System.loadLibrary("iconv");
    }
    
    ImageScanner scanner;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qr);
        
        autoFocusHandler = new Handler();
        mCamera = getCameraInstance();
        
        // Instance barcode scanner
        scanner = new ImageScanner();
        scanner.setConfig(0, Config.X_DENSITY, 3);
        scanner.setConfig(0, Config.Y_DENSITY, 3);

        mPreview = new CameraPreview(this, mCamera, previewCb, autoFocusCB);
        FrameLayout preview = (FrameLayout)findViewById(R.id.cameraPreview);
        preview.addView(mPreview);
        
        mpCamera = MediaPlayer.create(this, R.raw.camera);
        mpTick = MediaPlayer.create(this, R.raw.tick);
        
        // Listening to back button
		ImageView backButton = (ImageView) findViewById(R.id.backbutton);
		backButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View arg0) {
                aCounter.cancel();
                aCounter=null;
                finish();
            }
        });
        
        // Timer
        aCounter = new CountDownTimer(20000, 1000) {
            public void onTick(long millisUntilFinished) {
                if (millisUntilFinished <= 5000){
                    mpTick.seekTo(0);
                    mpTick.start();
                }
            }
            public void onFinish() {
                finish();
            }
        }.start();
    }
    
	public void onPause() {
        super.onPause();
        releaseCamera();
    }

	/** A safe way to get an instance of the Camera object. */
	public static Camera getCameraInstance(){
	    Camera c = null;
	    
    	Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
        int cameraCount = Camera.getNumberOfCameras();
        for (int camIdx = 0; camIdx < cameraCount; camIdx++) {
            Camera.getCameraInfo(camIdx, cameraInfo);
            if (cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                try {
                    c = Camera.open(camIdx);
                } catch (RuntimeException e) {
                }
            }
        }
	    return c;
	}
	
	private void releaseCamera() {
	    if (mCamera != null) {
	        previewing = false;
	        mCamera.setPreviewCallback(null);
	        mCamera.release();
	        mCamera = null;
	    }
	}
	
	private Runnable doAutoFocus = new Runnable() {
	        public void run() {
	            if (previewing)
	                mCamera.autoFocus(autoFocusCB);
	        }
	    };
	
	PreviewCallback previewCb = new PreviewCallback() {
        public void onPreviewFrame(byte[] data, Camera camera) {
            Camera.Parameters parameters = camera.getParameters();
            Size size = parameters.getPreviewSize();

            Image barcode = new Image(size.width, size.height, "Y800");
		    barcode.setData(data);
		
		    int result = scanner.scanImage(barcode);
		    
		    if (result != 0) {
				releaseCamera();
		        SymbolSet syms = scanner.getResults();
		        
		        for (Symbol sym : syms) {
                    System.out.println("QR Java "+sym.getData());
		        	mpCamera.start();
                    db = new MyDBHandler(getApplicationContext());
                    db.updateQR(sym.getData());
		        }
                
                aCounter.cancel();
                aCounter=null;
                
				scanner.destroy();
				barcode.destroy();
				scanner = null;
				barcode = null;
                finish();
		    }
	    }
	};
	
	// Mimic continuous auto-focusing
	AutoFocusCallback autoFocusCB = new AutoFocusCallback() {
	        public void onAutoFocus(boolean success, Camera camera) {
	        	autoFocusHandler.postDelayed(doAutoFocus, 1000);
	        }
	};

	@Override
	public void onDestroy() {
		super.onDestroy();
		releaseCamera();
		System.gc();
	}


}
