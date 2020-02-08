#include <iostream>
#include <cmath>
#include <algorithm>
#include "saturated_color_histogram.hh"

using namespace jir;
using namespace boost;
using namespace std;
using namespace cv;

SaturatedColorHistogram::SaturatedColorHistogram(unsigned int nr_bins_h, unsigned int nr_bins_s) : _nr_samples(0){
	_histSize[0] = int(nr_bins_h);
	_histSize[1] = int(nr_bins_s);

	_h_ranges[0] = 0.0;
	_h_ranges[1] = 180.0 + 0.01;

	_s_ranges[0] = 0.0;
	_s_ranges[1] = 256.0 + 0.01;

}

void SaturatedColorHistogram::normalize(void){
	if (_nr_samples == 0) return;
	for (int i_h = 0; i_h < get_nr_bins_h(); ++i_h){
		for (int i_s = 0; i_s < get_nr_bins_s(); ++i_s){
			_hist.at<float>(i_h, i_s) /= float(_nr_samples);
		}
	}
}

bool SaturatedColorHistogram::load(const Mat& color_img, const Mat& mask, bool accumulate){
	if (!accumulate){
		_nr_samples = 0;
	}

	Mat img1 = color_img;
	_nr_samples += color_img.total();

	Mat color_img_float(color_img.size(), CV_32FC3);
	color_img.convertTo(color_img_float, CV_32F, 1.0 / 255.0); // Each channel BGR is between 0.0 and 1.0 now

	_color_hs.create(color_img_float.size(), CV_32FC2); // The destination should be preallocated.

	cvtColor(color_img_float, _color_hs, CV_BGR2HSV);

	int channels[] = { 0, 1};
	const float* ranges[] = { _h_ranges, _s_ranges};

	calcHist(&_color_hs, 1, channels, mask /* Mat() if no mask */,
		_hist, 2, _histSize, ranges, true, accumulate);


	if (!accumulate){
		normalize();
	}

	return true;
}

bool SaturatedColorHistogram::load(const std::string& image_path_name, bool accumulate){
	_image_path_name = image_path_name;
	Mat color_img = imread(image_path_name.c_str());
	if (!color_img.data){
		std::cerr << "could not open " << image_path_name << endl;
		return false;
	}

	return load(color_img, Mat(), accumulate);
}

double SaturatedColorHistogram::compare(const SaturatedColorHistogram& other) const{
	double result = 0.0;
	result = cv::compareHist(_hist, other._hist, CV_COMP_BHATTACHARYYA);
	return result;
}
