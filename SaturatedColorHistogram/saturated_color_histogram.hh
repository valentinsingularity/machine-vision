
#ifndef __SATURATEDCOLORHISTOGRAM_HH__
#define __SATURATEDCOLORHISTOGRAM_HH__

#include <vector>
#include <ostream>
#include <string>
//#include <Eigen/Dense>
#include <boost/shared_ptr.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

namespace jir {

	/** A histogram based on binned h*s space.
	*/
	class SaturatedColorHistogram {
	public:

		/**
		* @param nr_bins_h h range is [0, 180]
		* @param nr_bins_s s range is [0, 256]
		*/
		SaturatedColorHistogram(
			unsigned int nr_bins_h = 180,
			unsigned int nr_bins_s = 256
			);

		/**
		* The normalization constant is nr_samples().
		*/
		void normalize(void);

		/** loads an image and computes its (normalized) histogram.
		* Normalization is only done if accumulate= false
		* @param image_path_name fully qualified path.
		* @param accumulate if true, the current histogram will not be reset but updated.
		* You should not load with accumulate=true after normalizing.
		* @return if successful.
		*/
		bool load(const std::string& image_path_name, bool accumulate = false);

		/**
		* Loads from the image using the mask. Normalization is only done if accumulate= false.
		* @param image of encoding CV_8UC3
		* @param mask
		* @param accumulate
		* @return
		*/
		bool load(const cv::Mat& image, const cv::Mat& mask, bool accumulate = false);

		/**
		* This is the normalization constant.
		*/
		int nr_samples(void){
			return _nr_samples;
		}

		/** Compare two histograms by using the Bhattacharyya distance.
		* Note: the object other should have been created using the same constructor parameter.
		*/
		double compare(const SaturatedColorHistogram& other) const;

		/**
		* @return the histogram is a 3D array of size nr_bins_h*nr_bins_s.
		* In OpenCV MatND is typedefed to just Mat.
		* Its elements can be accessed as hist(h_bin,s_bin).
		*/
		const cv::MatND& get_histogram(void) const{
			return _hist;
		}

		int get_nr_bins_h(void) const{
			return _histSize[0];
		}

		int get_nr_bins_s(void) const{
			return _histSize[1];
		}

		int get_nr_of_bins(void) const{
			return (_histSize[0] * _histSize[1]);
		}

		std::string image_path_name(void) const{
			return _image_path_name;
		}

		void set_image_path_name(std::string image_path_name){
			_image_path_name = image_path_name;
		}

		/**
		* @param v will be cleared and filled with the histogram values in the nested order
		*/
		// void get_histogram_as_vector(Eigen::VectorXf& v) const;

		/**
		* The opposite of get_histogram_as_vector
		*/
		//void set_histogram_from_vector(const Eigen::VectorXf& v,
		//		unsigned int nr_bins_h, unsigned int nr_bins_s);

	protected:
		int _histSize[2];
		float _h_ranges[2];
		float _s_ranges[2];
		cv::MatND _hist; ///< This will be normalized (sum=1) in the load function.
		int _nr_samples;
		cv::Mat _color_hs; // cached from the last computation
		std::string _image_path_name;
	};
}
#endif
