package com.example.nobodyflu

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.view.View
import androidx.core.content.ContextCompat
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import kotlin.math.max
import kotlin.math.min
import android.util.Log


class OverlayView(context: Context?, attrs: AttributeSet?) :
    View(context, attrs) {

    private var results: HandLandmarkerResult? = null
    private var linePaint = Paint()
    private var pointPaint = Paint()

    private var scaleFactor: Float = 1f
    private var imageWidth: Int = 1
    private var imageHeight: Int = 1
    var lastFingerCount: Int = 0

    private var stableFingerCount = 0        // Last stable count
private var lastDetectedCount = 0        // Last detected in frame
private var sameCountFrames = 0          // How many frames the same number appeared
private val REQUIRED_STABLE_FRAMES = 3   // Number of consecutive frames to accept



    init {
        initPaints()
    }

    fun clear() {
        results = null
        linePaint.reset()
        pointPaint.reset()
        invalidate()
        initPaints()
    }

    private fun initPaints() {
        linePaint.color =
            ContextCompat.getColor(context!!, android.R.color.black)
        linePaint.strokeWidth = LANDMARK_STROKE_WIDTH
        linePaint.style = Paint.Style.STROKE

        pointPaint.color = Color.YELLOW
        pointPaint.strokeWidth = LANDMARK_STROKE_WIDTH
        pointPaint.style = Paint.Style.FILL
    }

    override fun draw(canvas: Canvas) {
        super.draw(canvas)
        results?.let { handLandmarkerResult ->
            for (landmark in handLandmarkerResult.landmarks()) {
                for (normalizedLandmark in landmark) {
                    canvas.drawPoint(
                        normalizedLandmark.x() * imageWidth * scaleFactor,
                        normalizedLandmark.y() * imageHeight * scaleFactor,
                        pointPaint
                    )
                }

                HandLandmarker.HAND_CONNECTIONS.forEach {
                    canvas.drawLine(
                        landmark.get(it!!.start())
                            .x() * imageWidth * scaleFactor,
                        landmark.get(it.start())
                            .y() * imageHeight * scaleFactor,
                        landmark.get(it.end())
                            .x() * imageWidth * scaleFactor,
                        landmark.get(it.end())
                            .y() * imageHeight * scaleFactor,
                        linePaint
                    )
                }
            }
        }
    }

    fun setResults(
        handLandmarkerResults: HandLandmarkerResult,
        imageHeight: Int,
        imageWidth: Int,
        runningMode: RunningMode = RunningMode.IMAGE
    ) {
        results = handLandmarkerResults

        this.imageHeight = imageHeight
        this.imageWidth = imageWidth

        scaleFactor = when (runningMode) {
            RunningMode.IMAGE,
            RunningMode.VIDEO -> {
                min(width * 1f / imageWidth, height * 1f / imageHeight)
            }
            RunningMode.LIVE_STREAM -> {
                max(width * 1f / imageWidth, height * 1f / imageHeight)
            }
        }

        var totalFingersAllHands = 0  // initialize counter for all hands

        handLandmarkerResults.landmarks().forEachIndexed { handIndex, landmarks ->
            val raised = FingerUtils.detectRaisedFingers(landmarks)
            Log.d("FingerState", "Hand $handIndex: $raised")

            // Count how many fingers are raised
            val totalRaised = raised.values.count { it }  // now uses the correct variable
            Log.d("FingerCount", "Hand $handIndex has $totalRaised fingers raised")
            totalFingersAllHands += totalRaised  // add to total across all hands
        }

        // Stability logic
if (totalFingersAllHands == lastDetectedCount) {
    sameCountFrames++
} else {
    lastDetectedCount = totalFingersAllHands
    sameCountFrames = 1
}

if (sameCountFrames >= REQUIRED_STABLE_FRAMES) {
    stableFingerCount = totalFingersAllHands
}

// Save the stable value for MyCameraView
lastFingerCount = stableFingerCount

        // Log total fingers across both hands
        Log.d("FingerCount", "Total fingers raised across all hands: $totalFingersAllHands")

        invalidate()
    }

    companion object {
        private const val LANDMARK_STROKE_WIDTH = 8F
    }
}