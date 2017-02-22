package mx.geekbucket.qrtuki;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
 
/**
 * Implements the isWiFiEnabled() function in Lua.
 */
public class GetQR implements com.naef.jnlua.NamedJavaFunction {
   /**
    * Gets the name of the Lua function as it would appear in the Lua script.
    * @return Returns the name of the custom Lua function.
    */
   @Override
   public String getName() {
      return "init";
   }
 
   /**
    * This method is called when the Lua function is called.
    * 
 
    * Warning! This method is not called on the main UI thread.
    * @param luaState Reference to the Lua state.
    * Needed to retrieve the Lua function's parameters and to return 
    * values back to Lua.
    * @return Returns the number of values to be returned by the Lua function.
    */
   @Override
   public int invoke(com.naef.jnlua.LuaState luaState) {
       com.ansca.corona.CoronaActivity activity = com.ansca.corona.CoronaEnvironment.getCoronaActivity();
       
       Intent myIntent = new Intent(activity, QRActivity.class);
       activity.startActivity(myIntent);
 
      // Return 1 to indicate that this Lua function returns 1 value.
      return 1;
   }
}