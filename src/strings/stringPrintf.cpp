#include "strings/stringPrintf.h"

#include <cstdarg>
#include <cerrno>
#include <string>
#include <vector>

#include "strings/string_util.h"


namespace lotos2 {
	namespace strings {
		namespace {

// Overloaded wrappers around vsnprintf and vswprintf. The buf_size parameter
// is the size of the buffer. These return the number of characters in the
// formatted string excluding the NUL terminator. If the buffer is not
// large enough to accommodate the formatted string without truncation, they
// return the number of characters that would be in the fully-formatted string
// (vsnprintf, and vswprintf on Windows), or -1 (vswprintf on POSIX platforms).
inline int vsnprintfT(char* buffer, size_t buf_size, const char* format, va_list argptr)
{
	return strings::vsnprintf(buffer, buf_size, format, argptr);
}

// Templatized backend for StringPrintF/StringAppendF. This does not finalize
// the va_list, the caller is expected to do that.
template <class StringType>
static void StringAppendVT(StringType* dst, const typename StringType::value_type* format, va_list ap)
{
	// First try with a small fixed size buffer.
	// This buffer size should be kept in sync with StringUtilTest.GrowBoundary
	// and StringUtilTest.StringPrintfBounds.
	typename StringType::value_type stack_buf[1024];

	va_list ap_copy;
	GG_VA_COPY(ap_copy, ap);

	int result=vsnprintfT(stack_buf, arraysize(stack_buf), format, ap_copy);
	va_end(ap_copy);

	if (result>=0 && result<static_cast<int>(arraysize(stack_buf))) {
		// It fit.
		dst->append(stack_buf, result);
		return;
		}

	// Repeatedly increase buffer size until it fits.
	int mem_length=arraysize(stack_buf);
	while (true) {
		if (result<0) {
#if defined(OS_WIN)
			// On Windows, vsnprintfT always returns the number of characters in a
			// fully-formatted string, so if we reach this point, something else is
			// wrong and no amount of buffer-doubling is going to fix it.
			return;
#else
			if (errno!=0 && errno!=EOVERFLOW) {
				return;
				}
			// Try doubling the buffer size.
			mem_length*=2;
#endif
			}
		else {
			// We need exactly "result + 1" characters.
			mem_length=result+1;
			}

		if (mem_length > 32*1024*1024) {
			// That should be plenty, don't try anything larger. This protects
			// against huge allocations when using vsnprintfT implementations that
			// return -1 for reasons other than overflow without setting errno.
			return;
			}

		std::vector<typename StringType::value_type> mem_buf(mem_length);

		// NOTE: You can only use a va_list once. Since we're in a while loop, we
		// need to make a new copy each time so we don't use up the original.
		GG_VA_COPY(ap_copy, ap);
		result=vsnprintfT(&mem_buf[0], mem_length, format, ap_copy);
		va_end(ap_copy);

		if ((result>=0) && (result<mem_length)) {
			// It fit
			dst->append(&mem_buf[0], result);
			return;
			}
		}
}

	} // namespace

std::string StringPrintf(const char* format, ...)
{
	va_list ap;
	va_start(ap, format);
	std::string result;
	StringAppendV(&result, format, ap);
	va_end(ap);
	return result;
}

std::string StringPrintV(const char* format, va_list ap)
{
	std::string result;
	StringAppendV(&result, format, ap);
	return result;
}

void StringAppendV(std::string* dst, const char* format, va_list ap)
{
	StringAppendVT(dst, format, ap);
}

	} // namespace strings
} // namespace lotos2