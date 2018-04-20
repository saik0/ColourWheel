package com.stylingandroid.colourwheel

import android.content.Context
import android.graphics.Bitmap
import android.os.SystemClock
import android.renderscript.Allocation
import android.renderscript.RenderScript
import android.util.Log
import kotlinx.coroutines.experimental.*
import kotlinx.coroutines.experimental.android.UI
import kotlin.properties.ReadWriteProperty
import kotlin.reflect.KProperty

class BitmapGenerator(
    private val androidContext: Context,
    private val config: Bitmap.Config,
    private val observer: BitmapObserver
) : ReadWriteProperty<Any, Byte> {

    private val size = Size(0, 0)

    var brightness = Byte.MAX_VALUE

    private var generateProcess: Job? = null

    private val generated = AutoCreate(Bitmap::recycle) {
        Bitmap.createBitmap(size.width, size.height, config)
    }

    private var rsCreation: Deferred<RenderScript> = async(CommonPool) {
        RenderScript.create(androidContext).also {
            _renderscript = it
        }
    }

    private var _renderscript: RenderScript? = null
    private val renderscript: RenderScript
        get() {
            assert(rsCreation.isCompleted)
            return _renderscript as RenderScript
        }

    private val generatedAllocation = AutoCreate(Allocation::destroy) {
        Allocation.createFromBitmap(
            renderscript,
            generated.value,
            Allocation.MipmapControl.MIPMAP_NONE,
            Allocation.USAGE_SCRIPT
        )
    }

    private val colourWheelScript = AutoCreate(ScriptC_ColourWheel::destroy) {
        ScriptC_ColourWheel(renderscript)
    }

    override fun getValue(thisRef: Any, property: KProperty<*>): Byte =
        brightness

    override fun setValue(thisRef: Any, property: KProperty<*>, value: Byte) {
        brightness = value
        generate()
    }

    fun setSize(width: Int, height: Int) {
        size.takeIf { it.width != width || it.height != height }?.also {
            generated.clear()
            generatedAllocation.clear()
        }
        size.width = width
        size.height = height
        generate()
    }

    private fun generate() {
        if (size.hasDimensions && generateProcess?.isCompleted != false) {
            generateProcess = launch(CommonPool) {
                rsCreation.await()
                generated.value.also {
                    val start = SystemClock.elapsedRealtime()
                    draw(it)
                    val elapsed = SystemClock.elapsedRealtime() - start
                    launch(UI) {
                        observer.bitmapChanged(it)
                        Log.d("BitmapGenerator", "draw elapsed: $elapsed")
                    }
                }
            }
        }
    }

    private fun generateBlocking() {
        Bitmap.createBitmap(size.width, size.height, config).also {
            draw(it)
            observer.bitmapChanged(it)
        }
    }

    private fun draw(bitmap: Bitmap) {
        generatedAllocation.value.apply {
            copyFrom(bitmap)
            colourWheelScript.value.invoke_colourWheel(
                colourWheelScript.value,
                this,
                brightness.toFloat() / Byte.MAX_VALUE.toFloat()
            )
            copyTo(bitmap)
        }
    }

    fun stop() {
        generated.clear()
        generatedAllocation.clear()
        colourWheelScript.clear()
        _renderscript?.destroy()
        rsCreation.takeIf { it.isActive }?.cancel()
    }

    interface BitmapObserver {
        fun bitmapChanged(bitmap: Bitmap)
    }

    private data class Size(var width: Int, var height: Int) {
        val hasDimensions
            get() = width > 0 && height > 0
    }

}
